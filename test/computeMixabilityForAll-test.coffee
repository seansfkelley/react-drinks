_ = require 'lodash'

{ _countSubsetMissing
  _includeAllGenerics
  _toMostGenericTags
  _computeSubstitutionMap
  _generateSearchResult
  computeMixabilityWithFuzziness } = require('../frontend/store/derived/computeMixabilityForAll').__test

makeIngredientsByTag = (array) ->
  ingredientsByTag = {}
  for i in array
    ingredientsByTag[i.tag] = i
  return ingredientsByTag

ingredient = (tag, generic = null) ->
  display = 'name-' + tag
  return { tag, generic, display }

recipe = (ingredients...) ->
  # This is very important: the recipes that are indexed do NOT have a generic flag.
  return {
    ingredients : _.map ingredients, (i) -> _.omit i, 'generic'
  }

IndexableIngredient = {
  A_ROOT      : ingredient 'a'
  A_CHILD_1   : ingredient 'a-1', 'a'
  A_CHILD_1_1 : ingredient 'a-1-1', 'a-1'
  A_CHILD_2   : ingredient 'a-2', 'a'
  A_CHILD_3   : ingredient 'a-3', 'a'
  B_ROOT      : ingredient 'b'
  Z_ROOT      : ingredient 'z'
  NULL        : ingredient()
}

ResultIngredient = _.mapValues IndexableIngredient, (i) -> _.omit i, 'generic'

describe 'computeMixabilityForAll', ->
  describe '#_includeAllGenerics', ->
    ingredientsByTag = makeIngredientsByTag [
      IndexableIngredient.A_ROOT
      IndexableIngredient.A_CHILD_1
      IndexableIngredient.A_CHILD_1_1
      IndexableIngredient.A_CHILD_2
    ]

    it 'should return an input ingredient with no generic', ->
      _includeAllGenerics({
        ingredients : [ IndexableIngredient.A_ROOT ]
        ingredientsByTag
      }).should.have.members [
        IndexableIngredient.A_ROOT
      ]

    it 'should return an ingredient and its single generic', ->
      _includeAllGenerics({
        ingredients : [ IndexableIngredient.A_CHILD_1 ]
        ingredientsByTag
      }).should.have.members [
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
      ]

    it 'should return an ingredient and its multiple generics', ->
      _includeAllGenerics({
        ingredients : [ IndexableIngredient.A_CHILD_1_1 ]
        ingredientsByTag
      }).should.have.members [
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_1_1
      ]

    it 'should not return any duplicates if multiple ingredients are the same', ->
      _includeAllGenerics({
        ingredients : [ IndexableIngredient.A_ROOT, IndexableIngredient.A_ROOT ]
        ingredientsByTag
      }).should.have.members [
        IndexableIngredient.A_ROOT
      ]

    it 'should not return any duplicates if multiple ingredients have the same generic', ->
      _includeAllGenerics({
        ingredients : [ IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_2 ]
        ingredientsByTag
      }).should.have.members [
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_2
      ]

  describe '#_toMostGenericTags', ->
    ingredientsByTag = makeIngredientsByTag [
      IndexableIngredient.A_ROOT
      IndexableIngredient.A_CHILD_1
      IndexableIngredient.A_CHILD_1_1
      IndexableIngredient.A_CHILD_2
    ]

    it 'should return the tag of an ingredient with no generic', ->
      _toMostGenericTags({
        ingredients : [ IndexableIngredient.A_ROOT ]
        ingredientsByTag
      }).should.have.members [
        IndexableIngredient.A_ROOT.tag
      ]

    it 'should return the tag of a generic of an ingredient', ->
      _toMostGenericTags({
        ingredients : [ IndexableIngredient.A_CHILD_1 ]
        ingredientsByTag
      }).should.have.members [
        IndexableIngredient.A_ROOT.tag
      ]

    it 'should return the tag of the most generic ancestor of an ingredient', ->
      _toMostGenericTags({
        ingredients : [ IndexableIngredient.A_CHILD_1_1 ]
        ingredientsByTag
      }).should.have.members [
        IndexableIngredient.A_ROOT.tag
      ]

    it 'should not return any duplicates if multiple ingredients are the same', ->
      _toMostGenericTags({
        ingredients : [ IndexableIngredient.A_ROOT, IndexableIngredient.A_ROOT ]
        ingredientsByTag
      }).should.have.members [
        IndexableIngredient.A_ROOT.tag
      ]

    it 'should not return any duplicates if multiple ingredients have the same generic', ->
      _toMostGenericTags({
        ingredients : [ IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_2 ]
        ingredientsByTag
      }).should.have.members [
        IndexableIngredient.A_ROOT.tag
      ]

  describe '#_computeSubstitutionMap', ->
    ingredientsByTag = makeIngredientsByTag [
      IndexableIngredient.A_ROOT
      IndexableIngredient.A_CHILD_1
      IndexableIngredient.A_CHILD_1_1
      IndexableIngredient.A_CHILD_1_1
    ]

    it 'should return a map from an ingredient to itself when given an ingredient with no generic', ->
      _computeSubstitutionMap({
        ingredients : [ IndexableIngredient.A_ROOT ]
        ingredientsByTag
      }).should.deep.equal {
        "#{IndexableIngredient.A_ROOT.tag}" : [ IndexableIngredient.A_ROOT.tag ]
      }

    it 'should return a map that includes direct descendants in their generic\'s entry when both are given', ->
      _computeSubstitutionMap({
        ingredients : [ IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1 ]
        ingredientsByTag
      }).should.deep.equal {
        "#{IndexableIngredient.A_ROOT.tag}"    : [ IndexableIngredient.A_ROOT.tag, IndexableIngredient.A_CHILD_1.tag ]
        "#{IndexableIngredient.A_CHILD_1.tag}" : [ IndexableIngredient.A_CHILD_1.tag ]
      }

    it 'should not include an inferred generic\'s tag as a value if that generic was not given', ->
      _computeSubstitutionMap({
        ingredients : [ IndexableIngredient.A_CHILD_1 ]
        ingredientsByTag
      }).should.deep.equal {
        "#{IndexableIngredient.A_ROOT.tag}"    : [ IndexableIngredient.A_CHILD_1.tag ]
        "#{IndexableIngredient.A_CHILD_1.tag}" : [ IndexableIngredient.A_CHILD_1.tag ]
      }

    it 'should return a map where each generic includes all descendant generations\' tags', ->
      _computeSubstitutionMap({
        ingredients : [
          IndexableIngredient.A_ROOT
          IndexableIngredient.A_CHILD_1
          IndexableIngredient.A_CHILD_1_1
        ]
        ingredientsByTag
      }).should.deep.equal {
        "#{IndexableIngredient.A_ROOT.tag}" : [
          IndexableIngredient.A_ROOT.tag
          IndexableIngredient.A_CHILD_1.tag
          IndexableIngredient.A_CHILD_1_1.tag
        ]
        "#{IndexableIngredient.A_CHILD_1.tag}" : [
          IndexableIngredient.A_CHILD_1.tag
          IndexableIngredient.A_CHILD_1_1.tag
        ]
        "#{IndexableIngredient.A_CHILD_1_1.tag}" : [
          IndexableIngredient.A_CHILD_1_1.tag
        ]
      }

    it 'should return a map where a generic with multiple descendants includes all their tags', ->
      _computeSubstitutionMap({
        ingredients : [
          IndexableIngredient.A_ROOT
          IndexableIngredient.A_CHILD_1
          IndexableIngredient.A_CHILD_2
        ]
        ingredientsByTag
      }).should.deep.equal {
        "#{IndexableIngredient.A_ROOT.tag}" : [
          IndexableIngredient.A_ROOT.tag
          IndexableIngredient.A_CHILD_1.tag
          IndexableIngredient.A_CHILD_2.tag
        ]
        "#{IndexableIngredient.A_CHILD_1.tag}" : [
          IndexableIngredient.A_CHILD_1.tag
        ]
        "#{IndexableIngredient.A_CHILD_2.tag}" : [
          IndexableIngredient.A_CHILD_2.tag
        ]
      }

  describe '#_countSubsetMissing', ->
    it 'should return how values in the first array are not in the second', ->
      _countSubsetMissing([ 1, 2, 3 ], [ 1, 4, 5 ]).should.equal 2

  # TODO: Many of these tests are sensitive to the ordering of the nested ingredient
  # arrays. I don't currently see a way in Mocha to get around this without picking
  # the result apart into multiple assertions.
  describe '#computeMixabilityWithFuzziness', ->
    makeArgs = (ingredientTags, recipes...) -> {
      recipes
      ingredientTags
      ingredientsByTag : makeIngredientsByTag [
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_1_1
        IndexableIngredient.A_CHILD_2
        IndexableIngredient.A_CHILD_3
        IndexableIngredient.B_ROOT
      ]
    }

    it 'should return the empty object for no results', ->
      computeMixabilityWithFuzziness(makeArgs([])).should.deep.equal {}

    # This is an upgrade consideration, if someone has a tag in localStorage but it's removed in later versions.
    it 'should should not throw an exception when given ingredients it doesn\'t understand', ->
      computeMixabilityWithFuzziness(makeArgs([
        IndexableIngredient.Z_ROOT.tag
      ])).should.deep.equal {}

    it 'should return results keyed by missing count', ->
      result = computeMixabilityWithFuzziness(makeArgs(
        [ IndexableIngredient.A_ROOT.tag ]
        recipe(IndexableIngredient.A_ROOT)
      ))

      result.should.have.all.keys [ '0' ]
      result['0'].should.be.an 'array'

    it 'should return a match for a recipe that matches exactly', ->
      computeMixabilityWithFuzziness(makeArgs(
        [ IndexableIngredient.A_ROOT.tag ]
        recipe(IndexableIngredient.A_ROOT)
      )).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_ROOT ]
          missing     : []
          substitute  : []
          available   : [ ResultIngredient.A_ROOT ]
        ]
      }

    it 'should consider ingredients without tags always available', ->
      computeMixabilityWithFuzziness(makeArgs(
        [ IndexableIngredient.A_ROOT.tag ]
        recipe(IndexableIngredient.A_ROOT, IndexableIngredient.NULL)
      )).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_ROOT, ResultIngredient.NULL ]
          missing     : []
          substitute  : []
          available   : [ ResultIngredient.A_ROOT, ResultIngredient.NULL ]
        ]
      }

    it 'should return a fuzzy match for a recipe (within 1) if there is at least one matching tag', ->
      args = makeArgs(
        [ IndexableIngredient.A_ROOT.tag ]
        recipe(IndexableIngredient.A_ROOT, IndexableIngredient.B_ROOT)
      )
      args.fuzzyMatchThreshold = 1
      computeMixabilityWithFuzziness(args).should.deep.equal {
        '1' : [
          ingredients : [ ResultIngredient.A_ROOT, ResultIngredient.B_ROOT ]
          missing     : [ ResultIngredient.B_ROOT ]
          substitute  : []
          available   : [ ResultIngredient.A_ROOT ]
        ]
      }

    it 'should not return a fuzzy match for a 1-ingredient recipe (within 1) if there are no matching tags', ->
      args = makeArgs(
        [ IndexableIngredient.B_ROOT.tag ]
        recipe(IndexableIngredient.A_ROOT)
      )
      args.fuzzyMatchThreshold = 1
      computeMixabilityWithFuzziness(args).should.deep.equal {}

    it 'should silently ignore input ingredients with no tags', ->
      computeMixabilityWithFuzziness(makeArgs(
        [ IndexableIngredient.A_ROOT.tag ]
        recipe(IndexableIngredient.A_ROOT, IndexableIngredient.NULL)
      )).should.have.all.keys [ '0' ]

    it 'should return an available match for a recipe if it calls for a parent (less specific) ingredient', ->
      computeMixabilityWithFuzziness(makeArgs(
        [ IndexableIngredient.A_CHILD_2.tag ]
        recipe(IndexableIngredient.A_ROOT)
      )).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_ROOT ]
          missing     : []
          substitute  : []
          available   : [ ResultIngredient.A_ROOT ]
        ]
      }
      # fuck I forgot the assertions

    it 'should return a substitutable match for a recipe if it calls for a sibling (equally specific) ingredient', ->
      computeMixabilityWithFuzziness(makeArgs(
        [ IndexableIngredient.A_CHILD_2.tag ]
        recipe(IndexableIngredient.A_CHILD_1)
      )).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_CHILD_1 ]
          missing     : []
          substitute  : [{
            need : ResultIngredient.A_CHILD_1
            have : [ ResultIngredient.A_CHILD_2.display ]
          }]
          available   : []
        ]
      }

    it 'should return a substitutable match for a recipe if it calls for a child (more specific) ingredient', ->
      computeMixabilityWithFuzziness(makeArgs(
        [ IndexableIngredient.A_ROOT.tag ]
        recipe(IndexableIngredient.A_CHILD_1)
      )).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_CHILD_1 ]
          missing     : []
          substitute  : [{
            need : ResultIngredient.A_CHILD_1
            have : [ ResultIngredient.A_ROOT.display ]
          }]
          available   : []
        ]
      }

    it 'should return multiple substitutable matches for a recipe (with sibling ingredients)', ->
      computeMixabilityWithFuzziness(makeArgs(
        [ IndexableIngredient.A_CHILD_2.tag, IndexableIngredient.A_CHILD_3.tag ]
        recipe(IndexableIngredient.A_CHILD_1)
      )).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_CHILD_1 ]
          missing     : []
          substitute  : [{
            need : ResultIngredient.A_CHILD_1
            have : [ ResultIngredient.A_CHILD_2.display, ResultIngredient.A_CHILD_3.display ]
          }]
          available   : []
        ]
      }

    it 'should count unknown recipe ingredients as missing', ->
      computeMixabilityWithFuzziness(makeArgs(
        [ IndexableIngredient.A_ROOT.tag ]
        recipe(IndexableIngredient.Z_ROOT, IndexableIngredient.A_ROOT)
      )).should.deep.equal {}

    it 'should maintain the relative ordering of input recipes', ->
      recipe1 = recipe IndexableIngredient.A_ROOT
      recipe1.sentinel = 1
      recipe2 = recipe IndexableIngredient.A_ROOT
      recipe2.sentinel = 2

      args12 = makeArgs [ IndexableIngredient.A_ROOT.tag ], recipe1, recipe2
      args21 = makeArgs [ IndexableIngredient.A_ROOT.tag ], recipe2, recipe1

      result12 = computeMixabilityWithFuzziness args12

      result12[0][0].sentinel.should.equal 1
      result12[0][1].sentinel.should.equal 2

      result21 = computeMixabilityWithFuzziness args21

      result21[0][0].sentinel.should.equal 2
      result21[0][1].sentinel.should.equal 1

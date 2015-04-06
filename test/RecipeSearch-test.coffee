# Should figure out how to include this in all Mocha setup cleanly.
require('loglevel').setLevel 'silent'

_      = require 'lodash'
should = require('chai').should()

RecipeSearch = require '../frontend/recipes/RecipeSearch'

ingredient = (tag, generic = null) ->
  display = 'name-' + tag
  return { tag, generic, display }

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

recipe = (ingredients...) ->
  # This is very important: the recipes that are indexed do NOT have a generic flag.
  return {
    ingredients : _.map ingredients, (i) -> _.omit i, 'generic'
  }

describe 'RecipeSearch', ->
  describe '#_includeAllGenerics', ->
    search = null
    beforeEach ->
      search = new RecipeSearch [
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_1_1
        IndexableIngredient.A_CHILD_2
      ]

    it 'should return an input ingredient with no generic', ->
      search._includeAllGenerics([ IndexableIngredient.A_ROOT ]).should.have.members [
        IndexableIngredient.A_ROOT
      ]

    it 'should return an ingredient and its single generic', ->
      search._includeAllGenerics([ IndexableIngredient.A_CHILD_1 ]).should.have.members [
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
      ]

    it 'should return an ingredient and its multiple generics', ->
      search._includeAllGenerics([ IndexableIngredient.A_CHILD_1_1 ]).should.have.members [
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_1_1
      ]

    it 'should not return any duplicates if multiple ingredients are the same', ->
      search._includeAllGenerics([ IndexableIngredient.A_ROOT, IndexableIngredient.A_ROOT ]).should.have.members [
        IndexableIngredient.A_ROOT
      ]

    it 'should not return any duplicates if multiple ingredients have the same generic', ->
      search._includeAllGenerics([ IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_2 ]).should.have.members [
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_2
      ]

  describe '#_toMostGenericTags', ->
    search = null
    beforeEach ->
      search = new RecipeSearch [
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_1_1
        IndexableIngredient.A_CHILD_2
      ]

    it 'should return the tag of an ingredient with no generic', ->
      search._toMostGenericTags([ IndexableIngredient.A_ROOT ]).should.have.members [
        IndexableIngredient.A_ROOT.tag
      ]

    it 'should return the tag of a generic of an ingredient', ->
      search._toMostGenericTags([ IndexableIngredient.A_CHILD_1 ]).should.have.members [
        IndexableIngredient.A_ROOT.tag
      ]

    it 'should return the tag of the most generic ancestor of an ingredient', ->
      search._toMostGenericTags([ IndexableIngredient.A_CHILD_1_1 ]).should.have.members [
        IndexableIngredient.A_ROOT.tag
      ]

    it 'should not return any duplicates if multiple ingredients are the same', ->
      search._toMostGenericTags([ IndexableIngredient.A_ROOT, IndexableIngredient.A_ROOT ]).should.have.members [
        IndexableIngredient.A_ROOT.tag
      ]

    it 'should not return any duplicates if multiple ingredients have the same generic', ->
      search._toMostGenericTags([ IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_2 ]).should.have.members [
        IndexableIngredient.A_ROOT.tag
      ]

  describe '#_computeSubstitutionMap', ->
    search = null
    beforeEach ->
      search = new RecipeSearch [
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_1_1
        IndexableIngredient.A_CHILD_1_1
      ]

    it 'should return a map from an ingredient to itself when given an ingredient with no generic', ->
      search._computeSubstitutionMap([ IndexableIngredient.A_ROOT ]).should.deep.equal {
        "#{IndexableIngredient.A_ROOT.tag}" : [ IndexableIngredient.A_ROOT.tag ]
      }

    it 'should return a map that includes direct descendants in their generic\'s entry when both are given', ->
      search._computeSubstitutionMap([ IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1 ]).should.deep.equal {
        "#{IndexableIngredient.A_ROOT.tag}"    : [ IndexableIngredient.A_ROOT.tag, IndexableIngredient.A_CHILD_1.tag ]
        "#{IndexableIngredient.A_CHILD_1.tag}" : [ IndexableIngredient.A_CHILD_1.tag ]
      }

    it 'should not include an inferred generic\'s tag as a value if that generic was not given', ->
      search._computeSubstitutionMap([ IndexableIngredient.A_CHILD_1 ]).should.deep.equal {
        "#{IndexableIngredient.A_ROOT.tag}"    : [ IndexableIngredient.A_CHILD_1.tag ]
        "#{IndexableIngredient.A_CHILD_1.tag}" : [ IndexableIngredient.A_CHILD_1.tag ]
      }

    it 'should return a map where each generic includes all descendant generations\' tags', ->
      search._computeSubstitutionMap([
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_1_1
      ]).should.deep.equal {
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
      search._computeSubstitutionMap([
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_2
      ]).should.deep.equal {
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
      RecipeSearch._countSubsetMissing([ 1, 2, 3 ], [ 1, 4, 5 ]).should.equal 2

  # TODO: Many of these tests are sensitive to the ordering of the nested ingredient
  # arrays. I don't currently see a way in Mocha to get around this without picking
  # the result apart into multiple assertions.
  describe '#computeMixableRecipes', ->
    makeSearch = (recipes...) ->
      return new RecipeSearch([
        IndexableIngredient.A_ROOT
        IndexableIngredient.A_CHILD_1
        IndexableIngredient.A_CHILD_1_1
        IndexableIngredient.A_CHILD_2
        IndexableIngredient.A_CHILD_3
        IndexableIngredient.B_ROOT
      ], recipes)

    it 'should return the empty object for no results', ->
      makeSearch().computeMixableRecipes([]).should.deep.equal {}

    # This is an upgrade consideration, if someone has a tag in localStorage but it's removed in later versions.
    it 'should should not throw an exception when given ingredients it doesn\'t understand', ->
      search = makeSearch()
      search.computeMixableRecipes([ IndexableIngredient.Z_ROOT.tag ]).should.deep.equal {}

    it 'should return results keyed by missing count', ->
      search = makeSearch recipe(IndexableIngredient.A_ROOT), recipe
      result = search.computeMixableRecipes [ IndexableIngredient.A_ROOT.tag ]

      result.should.have.all.keys [ '0' ]
      result['0'].should.be.an 'array'

    it 'should return a match for a recipe that matches exactly', ->
      search = makeSearch recipe(IndexableIngredient.A_ROOT)
      search.computeMixableRecipes([ IndexableIngredient.A_ROOT.tag ]).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_ROOT ]
          missing     : []
          substitute  : []
          available   : [ ResultIngredient.A_ROOT ]
        ]
      }

    it 'should consider ingredients without tags always available', ->
      search = makeSearch recipe(IndexableIngredient.A_ROOT, IndexableIngredient.NULL)
      search.computeMixableRecipes([ IndexableIngredient.A_ROOT.tag ]).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_ROOT, ResultIngredient.NULL ]
          missing     : []
          substitute  : []
          available   : [ ResultIngredient.A_ROOT, ResultIngredient.NULL ]
        ]
      }

    it 'should return a fuzzy match for a recipe (within 1) if there is at least one matching tag', ->
      search = makeSearch recipe(IndexableIngredient.A_ROOT, IndexableIngredient.B_ROOT)
      search.computeMixableRecipes([ IndexableIngredient.A_ROOT.tag ], 1).should.deep.equal {
        '1' : [
          ingredients : [ ResultIngredient.A_ROOT, ResultIngredient.B_ROOT ]
          missing     : [ ResultIngredient.B_ROOT ]
          substitute  : []
          available   : [ ResultIngredient.A_ROOT ]
        ]
      }

    it 'should not return a fuzzy match for a 1-ingredient recipe (within 1) if there are no matching tags', ->
      search = makeSearch recipe(IndexableIngredient.A_ROOT)
      search.computeMixableRecipes([ IndexableIngredient.B_ROOT.tag ], 1).should.deep.equal {}

    it 'should silently ignore input ingredients with no tags', ->
      search = makeSearch recipe(IndexableIngredient.A_ROOT, IndexableIngredient.NULL)
      search.computeMixableRecipes([ IndexableIngredient.A_ROOT.tag ]).should.have.all.keys [ '0' ]

    it 'should return an available match for a recipe if it calls for a parent (less specific) ingredient', ->
      search = makeSearch recipe(IndexableIngredient.A_ROOT)
      result = search.computeMixableRecipes([ IndexableIngredient.A_CHILD_2.tag ]).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_ROOT ]
          missing     : []
          substitute  : []
          available   : [ ResultIngredient.A_ROOT ]
        ]
      }

    it 'should return a substitutable match for a recipe if it calls for a sibling (equally specific) ingredient', ->
      search = makeSearch recipe(IndexableIngredient.A_CHILD_1)
      result = search.computeMixableRecipes([ IndexableIngredient.A_CHILD_2.tag ]).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_CHILD_1 ]
          missing     : []
          substitute  : [{ need : ResultIngredient.A_CHILD_1, have : [ ResultIngredient.A_CHILD_2.display ] }]
          available   : []
        ]
      }

    it 'should return a substitutable match for a recipe if it calls for a child (more specific) ingredient', ->
      search = makeSearch recipe(IndexableIngredient.A_CHILD_1)
      search.computeMixableRecipes([ IndexableIngredient.A_ROOT.tag ]).should.deep.equal {
        '0' : [
          ingredients : [ ResultIngredient.A_CHILD_1 ]
          missing     : []
          substitute  : [ { need : ResultIngredient.A_CHILD_1, have : [ ResultIngredient.A_ROOT.display ] }]
          available   : []
        ]
      }

    it 'should return multiple substitutable matches for a recipe (with sibling ingredients)', ->
      search = makeSearch recipe(IndexableIngredient.A_CHILD_1)
      search.computeMixableRecipes([ IndexableIngredient.A_CHILD_2.tag, IndexableIngredient.A_CHILD_3.tag ]).should.deep.equal {
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
      search = makeSearch recipe(IndexableIngredient.Z_ROOT, IndexableIngredient.A_ROOT)
      search.computeMixableRecipes([ IndexableIngredient.A_ROOT.tag ]).should.deep.equal {}

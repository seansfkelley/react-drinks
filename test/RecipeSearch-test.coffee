_      = require 'lodash'
should = require('chai').should()

RecipeSearch = require '../frontend/recipes/RecipeSearch'

ingredient = (tag, generic = null) ->
  return { tag, generic, _id : _.uniqueId() }

INGREDIENT_A_ROOT      = ingredient 'a'
INGREDIENT_A_CHILD_1   = ingredient 'a-1', 'a'
INGREDIENT_A_CHILD_1_1 = ingredient 'a-1-1', 'a-1'
INGREDIENT_A_CHILD_2   = ingredient 'a-2', 'a'

INGREDIENT_B_ROOT      = ingredient 'b'

recipe = (ingredients...) ->
  return { ingredients }

describe 'RecipeSearch', ->
  describe '#_includeAllGenerics', ->
    search = null
    beforeEach ->
      search = new RecipeSearch [
        INGREDIENT_A_ROOT
        INGREDIENT_A_CHILD_1
        INGREDIENT_A_CHILD_1_1
        INGREDIENT_A_CHILD_2
      ]

    it 'should return an input ingredient with no generic', ->
      search._includeAllGenerics([ INGREDIENT_A_ROOT ]).should.have.members [
        INGREDIENT_A_ROOT
      ]

    it 'should return an ingredient and its single generic', ->
      search._includeAllGenerics([ INGREDIENT_A_CHILD_1 ]).should.have.members [
        INGREDIENT_A_ROOT
        INGREDIENT_A_CHILD_1
      ]

    it 'should return an ingredient and its multiple generics', ->
      search._includeAllGenerics([ INGREDIENT_A_CHILD_1_1 ]).should.have.members [
        INGREDIENT_A_ROOT
        INGREDIENT_A_CHILD_1
        INGREDIENT_A_CHILD_1_1
      ]

    it 'should not return any duplicates if multiple ingredients are the same', ->
      search._includeAllGenerics([ INGREDIENT_A_ROOT, INGREDIENT_A_ROOT ]).should.have.members [
        INGREDIENT_A_ROOT
      ]

    it 'should not return any duplicates if multiple ingredients have the same generic', ->
      search._includeAllGenerics([ INGREDIENT_A_CHILD_1, INGREDIENT_A_CHILD_2 ]).should.have.members [
        INGREDIENT_A_ROOT
        INGREDIENT_A_CHILD_1
        INGREDIENT_A_CHILD_2
      ]

  describe '#_toMostGenericTags', ->
    search = null
    beforeEach ->
      search = new RecipeSearch [
        INGREDIENT_A_ROOT
        INGREDIENT_A_CHILD_1
        INGREDIENT_A_CHILD_1_1
        INGREDIENT_A_CHILD_2
      ]

    it 'should return the tag of an ingredient with no generic', ->
      search._toMostGenericTags([ INGREDIENT_A_ROOT ]).should.have.members [
        INGREDIENT_A_ROOT.tag
      ]

    it 'should return the tag of a generic of an ingredient', ->
      search._toMostGenericTags([ INGREDIENT_A_CHILD_1 ]).should.have.members [
        INGREDIENT_A_ROOT.tag
      ]

    it 'should return the tag of the most generic ancestor of an ingredient', ->
      search._toMostGenericTags([ INGREDIENT_A_CHILD_1_1 ]).should.have.members [
        INGREDIENT_A_ROOT.tag
      ]

    it 'should not return any duplicates if multiple ingredients are the same', ->
      search._toMostGenericTags([ INGREDIENT_A_ROOT, INGREDIENT_A_ROOT ]).should.have.members [
        INGREDIENT_A_ROOT.tag
      ]

    it 'should not return any duplicates if multiple ingredients have the same generic', ->
      search._toMostGenericTags([ INGREDIENT_A_CHILD_1, INGREDIENT_A_CHILD_2 ]).should.have.members [
        INGREDIENT_A_ROOT.tag
      ]

  describe '#_countSubsetMissing', ->
    it 'should return how values in the first array are not in the second', ->
      RecipeSearch._countSubsetMissing([ 1, 2, 3 ], [ 1, 4, 5 ]).should.equal 2

  describe '#computeMixableRecipes', ->
    makeSearch = (recipes...) ->
      return new RecipeSearch([
        INGREDIENT_A_ROOT
        INGREDIENT_A_CHILD_1
        INGREDIENT_A_CHILD_1_1
        INGREDIENT_A_CHILD_2
      ], recipes)

    it 'should return the empty object for no results', ->
      makeSearch().computeMixableRecipes([]).should.deep.equal {}

    it 'should return results keyed by missing count', ->
      search = makeSearch recipe(INGREDIENT_A_ROOT), recipe
      result = search.computeMixableRecipes [ INGREDIENT_A_ROOT.tag ]

      result.should.have.all.keys [ '0' ]
      result['0'].should.be.an 'array'

    it 'should return a match for a recipe that matches exactly', ->
      search = makeSearch recipe(INGREDIENT_A_ROOT)
      search.computeMixableRecipes([ INGREDIENT_A_ROOT.tag ]).should.deep.equal {
        '0' : [
          ingredients : [ INGREDIENT_A_ROOT ]
          missing     : []
          substitute  : []
          available   : [ INGREDIENT_A_ROOT ]
        ]
      }

    it 'should return a fuzzy match for a recipe (within 1) if there is at least one matching tag'
    it 'should not return a fuzzy match for a 1-ingredient recipe (within 1) if there are no matching tags'
    it 'should silently ignore ingredients with no tags'
    it 'should return a match for a recipe if it calls for generics'
    it 'should return a match for a recipe if it calls for substitutable ingredients'

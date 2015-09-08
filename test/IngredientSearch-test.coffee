_ = require 'lodash'

IngredientSearch = require '../frontend/ingredients/IngredientSearch'

ingredient = (searchable...) ->
  return { searchable }

AGAVE = {
  searchable : [ 'agave' ]
}

describe 'IngredientSearch', ->
  describe '#filterIngredient', ->
    it 'should return true when given an exact match of a searchable term', ->
      IngredientSearch.filterIngredient(AGAVE, 'agave').should.be.true

    it 'should return true when given a strict substring of a searchable term', ->
      IngredientSearch.filterIngredient(AGAVE, 'gav').should.be.true

    it 'should return true when given a case-insensitive match of a searchable term', ->
      IngredientSearch.filterIngredient(AGAVE, 'GAV').should.be.true

    it 'should return false when given an all-whitespace search', ->
      IngredientSearch.filterIngredient(AGAVE, ' ').should.be.false

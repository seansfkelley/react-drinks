_ = require 'lodash'

filteredGroupedRecipes = require '../frontend/store/derived/filteredGroupedRecipes'
{ _baseLiquorFilter
  _searchTermFilter
  _recipeListFilter
  _sortAndGroupAlphabetical } = filteredGroupedRecipes.__test

{ ANY_BASE_LIQUOR } = require '../shared/definitions'

describe 'filteredGroupedRecipes', ->
  describe '#_baseLiquorFilter', ->
    RECIPE_A   = { base : [ 'a' ] }
    RECIPE_B   = { base : [ 'b' ] }
    RECIPE_A_B = { base : [ 'a', 'b' ] }

    RECIPE_A_STRING = { base : 'a' }
    RECIPE_B_STRING = { base : 'b' }

    RECIPE_NULL = {}
    RECIPE_OBJECT = { base : {} }

    it 'should return the list as-is if the filter is ANY_BASE_LIQUOR', ->
      _.filter([
        RECIPE_A
        RECIPE_B
      ], _baseLiquorFilter(ANY_BASE_LIQUOR)).should.deep.equal [
        RECIPE_A
        RECIPE_B
      ]

    it 'should filter recipes properly when their "base" property is a string', ->
      _.filter([
        RECIPE_A_STRING
        RECIPE_B_STRING
      ], _baseLiquorFilter('a')).should.deep.equal [
        RECIPE_A_STRING
      ]

    it 'should filter recipes properly when their "base" property is an array of strings', ->
      _.filter([
        RECIPE_A
        RECIPE_B
      ], _baseLiquorFilter('a')).should.deep.equal [
        RECIPE_A
      ]

    it 'should filter out recipes with no "base" property', ->
      _.filter([
        RECIPE_A
        RECIPE_NULL
      ], _baseLiquorFilter('a')).should.deep.equal [
        RECIPE_A
      ]

    it 'should filter out recipes with a non-string, non-array "base" property', ->
      _.filter([
        RECIPE_A
        RECIPE_OBJECT
      ], _baseLiquorFilter('a')).should.deep.equal [
        RECIPE_A
      ]

    it 'should retain recipes if any "base" matches when it\'s an array of strings', ->
      _.filter([
        RECIPE_A
        RECIPE_A_B
      ], _baseLiquorFilter('b')).should.deep.equal [
        RECIPE_A_B
      ]

  describe '#_mixabilityFilter', ->
    RECIPE_A = { recipeId : 'a' }
    RECIPE_B = { recipeId : 'b' }



  describe '#_searchTermFilter', ->
    RECIPES = [ 'a', 'b', 'c' ]
    # Other filtering behavior is tested by the recipeMatchesSearchTerm tests.
    # Perhaps that file should be inlined into this file?
    it 'should return the list as-is when the search term is all whitespace', ->
      _.filter(RECIPES, _searchTermFilter(' \t')).should.deep.equal RECIPES

  describe '#_recipeListFilter', ->
    RECIPE_A = { recipeId : 'a', isCustom : true }
    RECIPE_B = { recipeId : 'b' }
    RECIPES = [ RECIPE_A, RECIPE_B ]

    it 'should return the list as-is when set to filter \'all\'', ->
      _.filter(RECIPES, _recipeListFilter('all')).should.deep.equal RECIPES

    it 'should filter out recipes if its splits include any missing ingredients when filtering on \'mixable\'', ->
      splits = {
        'a' :
          missing    : [ 'ingredient-1' ]
          substitute : [ 'ingredient-2' ]
          available  : [ 'ingredient-3' ]
      }

      _.filter([
        RECIPE_A
      ], _recipeListFilter('mixable', splits, [])).should.deep.equal []

    it 'should not filter recipes out if its splits contain substitutes but no missing ingredients when filtering on \'mixable\'', ->
      splits = {
        'a' :
          missing    : []
          substitute : [ 'ingredient-1' ]
          available  : [ 'ingredient-2' ]
      }

      _.filter([
        RECIPE_A
      ], _recipeListFilter('mixable', splits, [])).should.deep.equal [
        RECIPE_A
      ]

    it 'should return an empty list when filtering on \'favorites\' with no favorites', ->
      _.filter(RECIPES, _recipeListFilter('favorites', {}, [])).should.deep.equal []

    it 'should return any recipes that match on the recipeId field when filtering on \'favorites\'', ->
      _.filter(RECIPES, _recipeListFilter('favorites', {}, [ 'b' ])).should.deep.equal [ RECIPE_B ]

    it 'should return any recipes with isCustom set when filtering on \'custom\'', ->
      _.filter(RECIPES, _recipeListFilter('custom')).should.deep.equal [ RECIPE_A ]

  describe '#_sortAndGroupAlphabetical', ->
    RECIPE_A   = { sortName : 'a1' }
    RECIPE_A_2 = { sortName : 'a2' }
    RECIPE_B   = { sortName : 'b' }
    RECIPE_1   = { sortName : '1' }
    RECIPE_2   = { sortName : '2' }

    it 'should group recipes based on the first character of their "sortName" property', ->
      _sortAndGroupAlphabetical([
        RECIPE_A
        RECIPE_A_2
        RECIPE_B
      ]).should.deep.equal [
        key     : 'a'
        recipes : [ RECIPE_A, RECIPE_A_2 ]
      ,
        key     : 'b'
        recipes : [ RECIPE_B ]
      ]

    it 'should group numerically-named recipes together', ->
      _sortAndGroupAlphabetical([
        RECIPE_A
        RECIPE_1
        RECIPE_2
      ]).should.deep.equal [
        key     : '#'
        recipes : [ RECIPE_1, RECIPE_2 ]
      ,
        key     : 'a'
        recipes : [ RECIPE_A ]
      ]

    it 'should sort the recipes in each group by their full "sortName" property', ->
      _sortAndGroupAlphabetical([
        # Note that the input order here is important!
        RECIPE_A_2
        RECIPE_A
      ]).should.deep.equal [
        key     : 'a'
        recipes : [ RECIPE_A, RECIPE_A_2 ]
      ]
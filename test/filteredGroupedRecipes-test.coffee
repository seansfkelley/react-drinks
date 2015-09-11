_ = require 'lodash'

filteredGroupedRecipes = require '../frontend/store/derived/filteredGroupedRecipes'
{ _baseLiquorFilter
  _mixabilityFilter
  _searchTermFilter
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
    FILTER_FIELD_NAMES = [ 'mixable', 'nearMixable', 'notReallyMixable' ]

    MIXABILITY_BY_ID = {
      'a' : 0
      'b' : 1
      'c' : 2
    }

    RECIPES = [
      recipeId : 'a'
    ,
      recipeId : 'b'
    ,
      recipeId : 'c'
    ]

    TEST_CASES = [
      inputFilters : []
      outputIds    : []
    ,
      inputFilters : [ 'mixable' ]
      outputIds    : [ 'a' ]
    ,
      inputFilters : [ 'nearMixable' ]
      outputIds    : [ 'b' ]
    ,
      inputFilters : [ 'notReallyMixable' ]
      outputIds    : [ 'c' ]
    ,
      inputFilters : [ 'mixable', 'nearMixable' ]
      outputIds    : [ 'a', 'b' ]
    ,
      inputFilters : [ 'mixable', 'notReallyMixable' ]
      outputIds    : [ 'a', 'c' ]
    ,
      inputFilters : [ 'nearMixable', 'notReallyMixable' ]
      outputIds    : [ 'b', 'c' ]
    ,
      inputFilters : [ 'mixable', 'nearMixable', 'notReallyMixable' ]
      outputIds    : [ 'a', 'b', 'c' ]
    ]

    _.each TEST_CASES, ({ inputFilters, outputIds }) ->
      filterString = switch inputFilters.length
        when 0 then 'no filters are set'
        when 1 then "'#{inputFilters[0]}' is set"
        when 2 then "'#{inputFilters[0]}' and '#{inputFilters[1]}' are set"
        when 3 then "'#{inputFilters[0]}', '#{inputFilters[1]}' and '#{inputFilters[2]}' are set"
      mixabilityFilters =_.extend _.map(FILTER_FIELD_NAMES, (field) ->
        return { "#{field}" : _.contains(inputFilters, field) }
      )...
      outputRecipes = _.filter RECIPES, (r) -> _.contains outputIds, r.recipeId
      it "should properly filter when #{filterString}", ->
        _.filter(RECIPES, _mixabilityFilter(MIXABILITY_BY_ID, mixabilityFilters)).should.deep.equal outputRecipes


  describe '#_searchTermFilter', ->
    RECIPES = [ 'a', 'b', 'c' ]
    # Other filtering behavior is tested by the recipeMatchesSearchTerm tests.
    # Perhaps that file should be inlined into this file?
    it 'should return the list as-is when the search term is all whitespace', ->
      _.filter(RECIPES, _searchTermFilter(' \t')).should.deep.equal RECIPES

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

  # I don't like this contract very much -- this function should only filter, not attach
  # random metadata. Perhaps another derived property that maps from ID to missing (etc.),
  # just like mixability by ID is computed?
  it 'should return recipes with "available", "substitute" and "missing" fields', ->
    recipe = filteredGroupedRecipes({
      ingredientsByTag  : {}
      recipes           : [
        ingredients : []
        sortName    : 'a'
      ]
      ingredientTags    : []
      mixabilityFilters :
        mixable          : true
        nearMixable      : true
        notReallyMixable : true
    })[0].recipes[0]

    recipe.should.have.property 'available'
    recipe.should.have.property 'substitute'
    recipe.should.have.property 'missing'

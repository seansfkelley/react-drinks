_ = require 'lodash'

filteredGroupedRecipes = require '../frontend/store/derived/filteredGroupedRecipes'
{ _baseLiquorFilter
  _mixabilityFilter
  _searchTermFilter
  _sortAndGroupAlphabetical } = filteredGroupedRecipes.__test

describe 'filteredGroupedRecipes', ->
  describe '#_baseLiquorFilter', ->
    it 'should return the list as-is is the filter is "any"'

    it 'should filter recipes properly when their "base" property is a string'

    it 'should filter recipes properly when their "base" property is an array of string'

    it 'should filter out recipes with no "base" property'

    it 'should filter out recipes with a non-string, non-array "base" property'

  describe '#_mixabilityFilter', ->
    FILTER_FIELD_NAMES = [ 'mixable', 'nearMixable', 'notReallyMixable' ]

    TEST_CASES = [
      inputFilters : []
      outputIds    : []
    ,
      inputFilters : [ 'mixable' ]
      outputIds    : []
    ,
      inputFilters : [ 'nearMixable' ]
      outputIds    : []
    ,
      inputFilters : [ 'notReallyMixable' ]
      outputIds    : []
    ,
      inputFilters : [ 'mixable', 'nearMixable' ]
      outputIds    : []
    ,
      inputFilters : [ 'mixable', 'notReallyMixable' ]
      outputIds    : []
    ,
      inputFilters : [ 'nearMixable', 'notReallyMixable' ]
      outputIds    : []
    ,
      inputFilters : [ 'mixable', 'nearMixable', 'notReallyMixable' ]
      outputIds    : []
    ]

    _.each TEST_CASES, ({ inputFilters, outputIds }) ->
      filterString = switch inputFilters.length
        when 0 then 'no filters are set'
        when 1 then "'#{inputFilters[0]}' is set"
        when 2 then "'#{inputFilters[0]}' and '#{inputFilters[1]}' are set"
        when 3 then "'#{inputFilters[0]}', '#{inputFilters[1]}' and '#{inputFilters[2]}' are set"
      it "should properly filter when #{filterString}"

  describe '#_searchTermFilter', ->
    # Other filtering behavior is tested by the recipeMatchesSearchTerm tests.
    # Perhaps that file should be inlined into this file?
    it 'should return the list as-is when the search term is all whitespace'

  describe '#_sortAndGroupAlphabetical', ->
    it 'should group recipes based on the first character of their "sortName" property'

    it 'should group numerically-named recipes together'

    it 'should sort the recipes in each group by their full "sortName" property'

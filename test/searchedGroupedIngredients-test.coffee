searchedGroupedIngredients = require '../frontend/store/derived/searchedGroupedIngredients'

describe 'searchedGroupedIngredients', ->
  # TODO: Should assert in the search that the searchable terms are already lowercase.
  # This is an expectation, but I don't have an assert that doesn't run in prod mode yet.
  GROUPED_INGREDIENTS = [
    name        : 'A'
    ingredients : [
      searchable : [ 'a', '1', 'alpha' ]
    ,
      searchable : [ 'a', '2' ]
    ]
  ,
    name        : 'B'
    ingredients : [
      searchable : [ 'b', '1' ]
    ,
      searchable : [ 'b', '2' ]
    ]
  ]

  toObjectArgs = (groupedIngredients, ingredientSearchTerm) -> {
    groupedIngredients
    ingredientSearchTerm
  }

  it 'should return grouped ingredients as-is when the search term is null', ->
    searchedGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, null)).should.deep.equal GROUPED_INGREDIENTS

  it 'should return grouped ingredients as-is when the search term is the empty string', ->
    searchedGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, '')).should.deep.equal GROUPED_INGREDIENTS

  it 'should return grouped ingredients as-is when the search term is whitespace-only', ->
    searchedGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, ' \t')).should.deep.equal GROUPED_INGREDIENTS

  it 'should return the empty list if nothing matches', ->
    searchedGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, 'fskjdhfk')).should.deep.equal []

  it 'should return one group with one match when one ingredient matches', ->
    searchedGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, 'alpha')).should.deep.equal [
      name        : 'A'
      ingredients : [
        searchable : [ 'a', '1', 'alpha' ]
      ]
    ]

  it 'should return multiple groups if there are matches in multiple groups', ->
    searchedGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, '1')).should.deep.equal [
      name        : 'A'
      ingredients : [
        searchable : [ 'a', '1', 'alpha' ]
      ]
    ,
      name        : 'B'
      ingredients : [
        searchable : [ 'b', '1' ]
      ]
    ]

  it 'should omit entire groups if they have no matching results', ->
    searchedGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, 'a')).should.deep.equal [
      name        : 'A'
      ingredients : [
        searchable : [ 'a', '1', 'alpha' ]
      ,
        searchable : [ 'a', '2' ]
      ]
    ]

  it 'should find the search term as a substring when matching', ->
    searchedGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, 'lph')).should.deep.equal [
      name        : 'A'
      ingredients : [
        searchable : [ 'a', '1', 'alpha' ]
      ]
    ]

  it 'should be case-insensitive when matching', ->
    searchedGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, 'ALPHA')).should.deep.equal [
      name        : 'A'
      ingredients : [
        searchable : [ 'a', '1', 'alpha' ]
      ]
    ]

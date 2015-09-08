derived = require '../frontend/store/derived'

describe 'derived', ->
  describe '#searchedGroupedIngredients', ->
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

    it 'should return grouped ingredients as-is when the search term is null', ->
      derived.searchedGroupedIngredients(GROUPED_INGREDIENTS, null).should.deep.equal GROUPED_INGREDIENTS

    it 'should return grouped ingredients as-is when the search term is the empty string', ->
      derived.searchedGroupedIngredients(GROUPED_INGREDIENTS, '').should.deep.equal GROUPED_INGREDIENTS

    it 'should return grouped ingredients as-is when the search term is whitespace-only', ->
      derived.searchedGroupedIngredients(GROUPED_INGREDIENTS, ' \t').should.deep.equal GROUPED_INGREDIENTS

    it 'should return the empty list if nothing matches', ->
      derived.searchedGroupedIngredients(GROUPED_INGREDIENTS, 'fskjdhfk').should.deep.equal []

    it 'should return one group with one match when one ingredient matches', ->
      derived.searchedGroupedIngredients(GROUPED_INGREDIENTS, 'alpha').should.deep.equal [
        name        : 'A'
        ingredients : [
          searchable : [ 'a', '1', 'alpha' ]
        ]
      ]

    it 'should return multiple groups if there are matches in multiple groups', ->
      derived.searchedGroupedIngredients(GROUPED_INGREDIENTS, '1').should.deep.equal [
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
      derived.searchedGroupedIngredients(GROUPED_INGREDIENTS, 'a').should.deep.equal [
        name        : 'A'
        ingredients : [
          searchable : [ 'a', '1', 'alpha' ]
        ,
          searchable : [ 'a', '2' ]
        ]
      ]

    it 'should find the search term as a substring when matching', ->
      derived.searchedGroupedIngredients(GROUPED_INGREDIENTS, 'lph').should.deep.equal [
        name        : 'A'
        ingredients : [
          searchable : [ 'a', '1', 'alpha' ]
        ]
      ]

    it 'should be case-insensitive when matching', ->
      derived.searchedGroupedIngredients(GROUPED_INGREDIENTS, 'ALPHA').should.deep.equal [
        name        : 'A'
        ingredients : [
          searchable : [ 'a', '1', 'alpha' ]
        ]
      ]

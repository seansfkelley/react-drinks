const filteredGroupedIngredients = require('../frontend/store/derived/filteredGroupedIngredients');

describe('filteredGroupedIngredients', function() {
  // TODO: Should assert in the search that the searchable terms are already lowercase.
  // This is an expectation, but I don't have an assert that doesn't run in prod mode yet.
  const GROUPED_INGREDIENTS = [{
    name        : 'A',
    ingredients : [
      {searchable : [ 'a', '1', 'alpha' ]}
    ,
      {searchable : [ 'a', '2' ]}
    ]
  }
  , {
    name        : 'B',
    ingredients : [
      {searchable : [ 'b', '1' ]}
    ,
      {searchable : [ 'b', '2' ]}
    ]
  }
  ];

  const toObjectArgs = (groupedIngredients, searchTerm) => ({
    groupedIngredients,
    searchTerm
  }) ;

  it('should return grouped ingredients as-is when the search term is null', () => filteredGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, null)).should.deep.equal(GROUPED_INGREDIENTS));

  it('should return grouped ingredients as-is when the search term is the empty string', () => filteredGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, '')).should.deep.equal(GROUPED_INGREDIENTS));

  it('should return grouped ingredients as-is when the search term is whitespace-only', () => filteredGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, ' \t')).should.deep.equal(GROUPED_INGREDIENTS));

  it('should return the empty list if nothing matches', () => filteredGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, 'fskjdhfk')).should.deep.equal([]));

  it('should return one group with one match when one ingredient matches', () =>
    filteredGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, 'alpha')).should.deep.equal([{
      name        : 'A',
      ingredients : [
        {searchable : [ 'a', '1', 'alpha' ]}
      ]
    }
    ]));

  it('should return multiple groups if there are matches in multiple groups', () =>
    filteredGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, '1')).should.deep.equal([{
      name        : 'A',
      ingredients : [
        {searchable : [ 'a', '1', 'alpha' ]}
      ]
    }
    , {
      name        : 'B',
      ingredients : [
        {searchable : [ 'b', '1' ]}
      ]
    }
    ]));

  it('should omit entire groups if they have no matching results', () =>
    filteredGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, 'a')).should.deep.equal([{
      name        : 'A',
      ingredients : [
        {searchable : [ 'a', '1', 'alpha' ]}
      ,
        {searchable : [ 'a', '2' ]}
      ]
    }
    ]));

  it('should find the search term as a substring when matching', () =>
    filteredGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, 'lph')).should.deep.equal([{
      name        : 'A',
      ingredients : [
        {searchable : [ 'a', '1', 'alpha' ]}
      ]
    }
    ]));

  return it('should be case-insensitive when matching', () =>
    filteredGroupedIngredients(toObjectArgs(GROUPED_INGREDIENTS, 'ALPHA')).should.deep.equal([{
      name        : 'A',
      ingredients : [
        {searchable : [ 'a', '1', 'alpha' ]}
      ]
    }
    ]));});

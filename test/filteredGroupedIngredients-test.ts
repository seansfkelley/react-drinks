import { expect } from 'chai';

import { makePartialProxy } from './testUtils';
import { Ingredient } from '../shared/types';
import { filteredGroupedIngredients } from '../frontend/store/derived/filteredGroupedIngredients';

describe('filteredGroupedIngredients', () => {
  function searchableIngredient(...searchable: string[]) {
    return makePartialProxy<Ingredient>({ searchable });
  }

  // TODO: Should assert in the search that the searchable terms are already lowercase.
  // This is an expectation, but I don't have an assert that doesn't run in prod mode yet.
  const GROUPED_INGREDIENTS = [{
    name: 'A',
    ingredients: [searchableIngredient('a', '1', 'alpha'), searchableIngredient('a', '2')]
  }, {
    name: 'B',
    ingredients: [searchableIngredient('b', '1'), searchableIngredient('b', '2')]
  }];

  function makeArgs(searchTerm: string | undefined) {
    return { groupedIngredients: GROUPED_INGREDIENTS, searchTerm };
  }

  it('should return grouped ingredients as-is when the search term is missing', () => {
    expect(filteredGroupedIngredients(makeArgs(undefined))).to.deep.equal(GROUPED_INGREDIENTS);
  });

  it('should return grouped ingredients as-is when the search term is the empty string', () => {
    expect(filteredGroupedIngredients(makeArgs(''))).to.deep.equal(GROUPED_INGREDIENTS);
  });

  it('should return grouped ingredients as-is when the search term is whitespace-only', () => {
    expect(filteredGroupedIngredients(makeArgs(' \t'))).to.deep.equal(GROUPED_INGREDIENTS);
  });

  it('should return the empty list if nothing matches', () => {
    expect(filteredGroupedIngredients(makeArgs('fskjdhfk'))).to.deep.equal([]);
  });

  it('should return one group with one match when one ingredient matches', () => {
    expect(filteredGroupedIngredients(makeArgs('alpha'))).to.deep.equal([{
      name: 'A',
      ingredients: [searchableIngredient('a', '1', 'alpha')]
    }]);
  });

  it('should return multiple groups if there are matches in multiple groups', () => {
    expect(filteredGroupedIngredients(makeArgs('1'))).to.deep.equal([{
      name: 'A',
      ingredients: [searchableIngredient('a', '1', 'alpha')]
      }, {
      name: 'B',
      ingredients: [searchableIngredient('b', '1')]
    }]);
  });

  it('should omit entire groups if they have no matching results', () => {
    expect(filteredGroupedIngredients(makeArgs('a'))).to.deep.equal([{
      name: 'A',
      ingredients: [searchableIngredient('a', '1', 'alpha'), searchableIngredient('a', '2')]
    }]);
  });

  it('should find the search term as a substring when matching', () => {
    expect(filteredGroupedIngredients(makeArgs('lph'))).to.deep.equal([{
      name: 'A',
      ingredients: [searchableIngredient('a', '1', 'alpha')]
    }]);
  });

  it('should be case-insensitive when matching', () => {
    expect(filteredGroupedIngredients(makeArgs('ALPHA'))).to.deep.equal([{
      name: 'A',
      ingredients: [searchableIngredient('a', '1', 'alpha')]
    }]);
  });
});


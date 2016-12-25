import { expect } from 'chai';

import { makePartialProxy } from './testUtils';
import { DisplayIngredient, Recipe } from '../shared/types';
import { ANY_BASE_LIQUOR } from '../shared/definitions';
import {
  _baseLiquorFilter,
  _searchTermFilter,
  _recipeListFilter,
  _sortAndGroupAlphabetical
} from '../frontend/store/derived/filteredGroupedRecipes';
import { IngredientSplit } from '../frontend/store/derived/ingredientSplitsByRecipeId';

describe('filteredGroupedRecipes', () => {
  describe('#_baseLiquorFilter', () => {
    function recipe(name: string, base: any) {
      return makePartialProxy<Recipe>({ name, recipeId: name, base });
    }

    const RECIPE_A = recipe('a', ['a']);
    const RECIPE_B = recipe('b', ['b']);
    const RECIPE_A_B = recipe('a_b', ['a', 'b']);
    const RECIPE_A_STRING = recipe('a_string', 'a');
    const RECIPE_B_STRING = recipe('b_string', 'b');
    const RECIPE_NO_BASE = recipe('no_base', undefined);
    const RECIPE_OBJECT = recipe('object', {} as any);

    it('should return the list as-is if the filter is ANY_BASE_LIQUOR', () => {
      expect([RECIPE_A, RECIPE_B].filter(_baseLiquorFilter(ANY_BASE_LIQUOR))).to.deep.equal([RECIPE_A, RECIPE_B]);
    });

    it('should filter recipes properly when their "base" property is a string', () => {
      expect([RECIPE_A_STRING, RECIPE_B_STRING].filter(_baseLiquorFilter('a'))).to.deep.equal([RECIPE_A_STRING]);
    });

    it('should filter recipes properly when their "base" property is an array of strings', () => {
      expect([RECIPE_A, RECIPE_B].filter(_baseLiquorFilter('a'))).to.deep.equal([RECIPE_A]);
    });

    it('should filter out recipes with no "base" property', () => {
      expect([RECIPE_A, RECIPE_NO_BASE].filter(_baseLiquorFilter('a'))).to.deep.equal([RECIPE_A]);
    });

    it('should filter out recipes with a non-string, non-array "base" property', () => {
      expect([RECIPE_A, RECIPE_OBJECT].filter(_baseLiquorFilter('a'))).to.deep.equal([RECIPE_A]);
    });

    it('should retain recipes if any "base" matches when it\'s an array of strings', () => {
      expect([RECIPE_A, RECIPE_A_B].filter(_baseLiquorFilter('b'))).to.deep.equal([RECIPE_A_B]);
    });
  });

  describe('#_searchTermFilter', () => {
    const RECIPES = [makePartialProxy<Recipe>({ name: 'foo'}), makePartialProxy<Recipe>({ name: 'bar' })];
    // Other filtering behavior is tested by the recipeMatchesSearchTerm tests.
    // Perhaps that file should be inlined into this file?
    it('should return the list as-is when the search term is all whitespace', () => {
      expect(RECIPES.filter(_searchTermFilter(' \t', {}))).to.deep.equal(RECIPES);
    });
  });

  describe('#_recipeListFilter', () => {
    const RECIPE_A = makePartialProxy<Recipe>({ recipeId: 'a', isCustom: true });
    const RECIPE_B = makePartialProxy<Recipe>({ recipeId: 'b', isCustom: undefined });
    const RECIPES = [RECIPE_A, RECIPE_B];

    function displayIngredient(name: string) {
      return makePartialProxy<DisplayIngredient>({ tag: name, displayIngredient: name });
    }

    it('should return the list as-is when set to filter \'all\'', () => {
      expect(RECIPES.filter(_recipeListFilter('all', {}, []))).to.deep.equal(RECIPES);
    });

    it('should filter out recipes if its splits include any missing ingredients when filtering on \'mixable\'', () => {
      const splits: { [recipeId: string]: IngredientSplit } = {
        'a': {
          available: [displayIngredient('foo')],
          missing: [displayIngredient('bar')],
          substitute: [{
            need: displayIngredient('baz'),
            have: [ 'quux' ]
          }]
        }
      };

      expect([RECIPE_A].filter(_recipeListFilter('mixable', splits, []))).to.deep.equal([]);
    });

    it('should not filter recipes out if its splits contain substitutes but no missing ingredients when filtering on \'mixable\'', () => {
      const splits: { [recipeId: string]: IngredientSplit } = {
        'a': {
          available: [displayIngredient('foo')],
          missing: [],
          substitute: [{
            need: displayIngredient('baz'),
            have: [ 'quux' ]
          }]
        }
      };

      expect([RECIPE_A].filter(_recipeListFilter('mixable', splits, []))).to.deep.equal([RECIPE_A]);
    });

    it('should return an empty list when filtering on \'favorites\' with no favorites', () => {
      expect(RECIPES.filter(_recipeListFilter('favorites', {}, []))).to.deep.equal([]);
    });

    it('should return any recipes that match on the recipeId field when filtering on \'favorites\'', () => {
      expect(RECIPES.filter(_recipeListFilter('favorites', {}, ['b']))).to.deep.equal([RECIPE_B]);
    });

    it('should return any recipes with isCustom set when filtering on \'custom\'', () => {
      expect(RECIPES.filter(_recipeListFilter('custom', {}, []))).to.deep.equal([RECIPE_A]);
    });
  });

  describe('#_sortAndGroupAlphabetical', () => {
    const RECIPE_A = makePartialProxy<Recipe>({ sortName: 'a1' });
    const RECIPE_A_2 = makePartialProxy<Recipe>({ sortName: 'a2' });
    const RECIPE_B = makePartialProxy<Recipe>({ sortName: 'b' });
    const RECIPE_1 = makePartialProxy<Recipe>({ sortName: '1' });
    const RECIPE_2 = makePartialProxy<Recipe>({ sortName: '2' });

    it('should group recipes based on the first character of their "sortName" property', () => {
      expect(_sortAndGroupAlphabetical([RECIPE_A, RECIPE_A_2, RECIPE_B])).to.deep.equal([{
        key: 'a',
        recipes: [RECIPE_A, RECIPE_A_2]
      }, {
        key: 'b',
        recipes: [RECIPE_B]
      }]);
    });

    it('should group numerically-named recipes together', () => {
      expect(_sortAndGroupAlphabetical([RECIPE_A, RECIPE_1, RECIPE_2])).to.deep.equal([{
        key: '#',
        recipes: [RECIPE_1, RECIPE_2]
      }, {
        key: 'a',
        recipes: [RECIPE_A]
      }]);
    });

    it('should sort the recipes in each group by their full "sortName" property', () => {
      // Note that the input order here is important!
      expect(_sortAndGroupAlphabetical([RECIPE_A_2, RECIPE_A])).to.deep.equal([{
        key: 'a',
        recipes: [RECIPE_A, RECIPE_A_2]
      }]);
    });
  });
});


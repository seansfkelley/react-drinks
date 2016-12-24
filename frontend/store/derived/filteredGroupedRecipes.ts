import { isString, isArray, sortBy, groupBy, map } from 'lodash';
import * as log from 'loglevel';

import { Ingredient, Recipe } from '../../../shared/types';
import { assert } from '../../../shared/tinyassert';
import { ANY_BASE_LIQUOR } from '../../../shared/definitions';
import { memoize } from './memoize';

import { IngredientSplit, memoized as ingredientSplitsByRecipeId }  from './ingredientSplitsByRecipeId';
import { memoized as recipeMatchesSearchTerm } from './recipeMatchesSearchTerm';

// hee hee
export function nofilter() {
  return true;
}

export function _baseLiquorFilter(baseLiquorFilter: string) {
  if (baseLiquorFilter !== ANY_BASE_LIQUOR) {
    return (recipe: Recipe) => {
      if (isString(recipe.base)) {
        return recipe.base === baseLiquorFilter;
      } else if (isArray(recipe.base)) {
        return recipe.base.includes(baseLiquorFilter);
      } else {
        log.warn(`recipe ${recipe.recipeId} ('${recipe.name}') has a non-string, non-array base: ${recipe.base}`);
        return false;
      }
    };
  } else {
    return nofilter;
  }
};

export function _searchTermFilter(searchTerm: string, ingredientsByTag: { [tag: string]: Ingredient }) {
  if (searchTerm.trim().length) {
    return (recipe: Recipe) => {
      return recipeMatchesSearchTerm({
        recipe,
        searchTerm,
        ingredientsByTag
      });
    };
  } else {
    return nofilter;
  }
};

export function _recipeListFilter(listType: string, ingredientSplits: { [recipeId: string]: IngredientSplit }, favoritedRecipeIds: string[]) {
  switch (listType) {
    case 'all':
      return nofilter;
    case 'mixable':
      return recipe => ingredientSplits[recipe.recipeId].missing.length === 0;
    case 'favorites':
      return recipe => favoritedRecipeIds.includes(recipe.recipeId);
    case 'custom':
      return recipe => !!recipe.isCustom;
    default:
      throw new Error(`unknown recipe list type '${listType}'`);
  }
}

export function _sortAndGroupAlphabetical(recipes: Recipe[]) {
  return sortBy(
    map(
      groupBy(
        sortBy(recipes, r => r.sortName),
        r => {
          const key = r.sortName[0].toLowerCase();
          if (/\d/.test(key)) {
            return '#';
          } else {
            return key;
          }
        }
      ),
      (recipes, key) => ({ recipes, key: key! })
    ),
    ({ key }) => key
  );
}

export function filteredGroupedRecipes({
  ingredientsByTag,
  recipes,
  baseLiquorFilter,
  searchTerm,
  ingredientTags,
  favoritedRecipeIds,
  selectedRecipeList
}: {
  ingredientsByTag: { [tag: string]: Ingredient },
  recipes: Recipe[],
  baseLiquorFilter: string,
  searchTerm: string,
  ingredientTags: string[],
  favoritedRecipeIds: string[],
  selectedRecipeList: string
}) {
  if (searchTerm == null) {
    searchTerm = '';
  }
  if (baseLiquorFilter == null) {
    baseLiquorFilter = ANY_BASE_LIQUOR;
  }

  const ingredientSplits = ingredientSplitsByRecipeId({ ingredientsByTag, recipes, ingredientTags });

  const filteredRecipes = recipes
    .filter(_baseLiquorFilter(baseLiquorFilter))
    .filter(_recipeListFilter(selectedRecipeList, ingredientSplits, favoritedRecipeIds))
    .filter(_searchTermFilter(searchTerm, ingredientsByTag));

  return _sortAndGroupAlphabetical(filteredRecipes);
};

export const memoized = memoize(filteredGroupedRecipes);

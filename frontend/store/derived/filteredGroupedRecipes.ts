import { isString, isArray, sortBy, groupBy, map } from 'lodash';
import * as log from 'loglevel';

import { Ingredient, Recipe } from '../../../shared/types';
import { RecipeListType, GroupedRecipes } from '../../types';
import { ANY_BASE_LIQUOR } from '../../../shared/definitions';

import { IngredientSplit }  from './ingredientSplitsByRecipeId';
import { recipeMatchesSearchTerm } from './recipeMatchesSearchTerm';

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

export function _recipeListFilter(listType: RecipeListType, ingredientSplits: { [recipeId: string]: IngredientSplit }, favoritedRecipeIds: string[]) {
  switch (listType) {
    case 'all':
      return nofilter;
    case 'mixable':
      return (recipe: Recipe) => ingredientSplits[recipe.recipeId].missing.length === 0;
    case 'favorites':
      return (recipe: Recipe) => favoritedRecipeIds.includes(recipe.recipeId);
    case 'custom':
      return (recipe: Recipe) => !!recipe.isCustom;
    default:
      throw new Error(`unknown recipe list type '${listType}'`);
  }
}

export function _hasAllSelectedIngredientsFilter(selectedIngredientTags: string[], ingredientSplits: { [recipeId: string]: IngredientSplit }) {
  if (selectedIngredientTags.length === 0) {
    return () => false;
  } else {
    return (recipe: Recipe) => {
      const splits = ingredientSplits[recipe.recipeId];
      return selectedIngredientTags.every(tag =>
        // TODO: This isn't the right logic for substitutes. I think to do it right we need to change the logic
        // in the ingredient splits computation; we can't do it with what it currently compute without recalculating
        // the generic parents of both ingredients or whatever.
        splits.available.some(s => s.tag === tag) || splits.substitute.some(s => s.need.tag === tag)
      );
    };
  }
}

export function _sortAndGroupAlphabetical(recipes: Recipe[]): GroupedRecipes[] {
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
  selectedIngredientTags,
  ingredientSplitsByRecipeId,
  // favoritedRecipeIds,
  // selectedRecipeList
}: {
  ingredientsByTag: { [tag: string]: Ingredient },
  recipes: Recipe[],
  baseLiquorFilter: string,
  searchTerm: string,
  selectedIngredientTags: string[],
  ingredientSplitsByRecipeId: { [recipeId: string]: IngredientSplit },
  favoritedRecipeIds: string[],
  selectedRecipeList: RecipeListType
}) {
  if (searchTerm == null) {
    searchTerm = '';
  }
  if (baseLiquorFilter == null) {
    baseLiquorFilter = ANY_BASE_LIQUOR;
  }

  const filteredRecipes = recipes
    .filter(_baseLiquorFilter(baseLiquorFilter))
    .filter(_hasAllSelectedIngredientsFilter(selectedIngredientTags, ingredientSplitsByRecipeId))
    // .filter(_recipeListFilter(selectedRecipeList, ingredientSplitsByRecipeId, favoritedRecipeIds))
    .filter(_searchTermFilter(searchTerm, ingredientsByTag));

  return _sortAndGroupAlphabetical(filteredRecipes);
};

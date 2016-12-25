import {} from 'lodash';

import { RootState } from '..';
import select from './select';

import { memoized as filteredGroupedRecipesFn } from './filteredGroupedRecipes';
import { memoized as ingredientSplitsByRecipeIdFn } from './ingredientSplitsByRecipeId';
import { memoized as filteredGroupedIngredientsFn } from './filteredGroupedIngredients';

function createSelector<T extends { [field: string]: any }, U>(fn: (args: T) => U, stateSelector: { [k in keyof T]: string }): (state: RootState) => U {
  return function(state: RootState) {
    // Trying to slam keyof and [key: string] together fucking sucks.
    return fn(select(state, stateSelector as any) as any);
  };
}

export const filteredGroupedRecipes = createSelector(
  filteredGroupedRecipesFn,
  {
    ingredientsByTag: 'ingredients.ingredientsByTag',
    recipes: 'recipes.alphabeticalRecipes',
    baseLiquorFilter: 'filters.baseLiquorFilter',
    searchTerm: 'filters.recipeSearchTerm',
    ingredientTags: 'filters.selectedIngredientTags',
    selectedRecipeList: 'filters.selectedRecipeList',
    favoritedRecipeIds: 'ui.favoritedRecipeIds'
  }
);

export const ingredientSplitsByRecipeId = createSelector(
  ingredientSplitsByRecipeIdFn,
  {
    recipes: 'recipes.alphabeticalRecipes',
    ingredientsByTag: 'ingredients.ingredientsByTag',
    ingredientTags: 'filters.selectedIngredientTags'
  }
);

export const filteredGroupedIngredients = createSelector(
  filteredGroupedIngredientsFn,
  {
    groupedIngredients: 'ingredients.groupedIngredients',
    searchTerm: 'filters.ingredientSearchTerm'
  }
)

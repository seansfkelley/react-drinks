import { createSelector } from 'reselect';

import { RootState } from './index';
import { filteredGroupedRecipes } from './derived/filteredGroupedRecipes';
import { ingredientSplitsByRecipeId } from './derived/ingredientSplitsByRecipeId';
import { filteredGroupedIngredients } from './derived/filteredGroupedIngredients';

const selectIngredientsByTag = (state: RootState) => state.ingredients.ingredientsByTag;
const selectGroupedIngredients = (state: RootState) => state.ingredients.groupedIngredients;

const selectRecipes = (state: RootState) => state.recipes.alphabeticalRecipes;

const selectBaseLiquorFilter = (state: RootState) => state.filters.baseLiquorFilter;
const selectRecipeSearchTerm = (state: RootState) => state.filters.recipeSearchTerm;
const selectIngredientSearchTerm = (state: RootState) => state.filters.ingredientSearchTerm;
const selectIngredientTags = (state: RootState) => state.filters.selectedIngredientTags;
const selectSelectedRecipeList = (state: RootState) => state.filters.selectedRecipeList;

const selectFavoritedRecipeIds = (state: RootState) => state.ui.favoritedRecipeIds;

// TODO: Selectors for alphabetical recipes and such.

export const selectFilteredGroupedIngredients = createSelector(
  selectGroupedIngredients,
  selectIngredientSearchTerm,
  (
    groupedIngredients,
    searchTerm
  ) => filteredGroupedIngredients({
    groupedIngredients,
    searchTerm
  })
)

export const selectIngredientSplitsByRecipeId = createSelector(
  selectRecipes,
  selectIngredientsByTag,
  selectIngredientTags,
  (
    recipes,
    ingredientsByTag,
    ingredientTags
  ) => ingredientSplitsByRecipeId({
    recipes,
    ingredientsByTag,
    ingredientTags
  })
);

export const selectFilteredGroupedRecipes = createSelector(
  selectIngredientsByTag,
  selectRecipes,
  selectBaseLiquorFilter,
  selectRecipeSearchTerm,
  selectFavoritedRecipeIds,
  selectSelectedRecipeList,
  selectIngredientSplitsByRecipeId,
  (
    ingredientsByTag,
    recipes,
    baseLiquorFilter,
    searchTerm,
    favoritedRecipeIds,
    selectedRecipeList,
    ingredientSplitsByRecipeId
  ) => filteredGroupedRecipes({
    ingredientsByTag,
    recipes,
    baseLiquorFilter,
    searchTerm,
    favoritedRecipeIds,
    selectedRecipeList,
    ingredientSplitsByRecipeId
  })
);

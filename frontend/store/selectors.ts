import { sortBy, mapValues, flatten } from 'lodash';
import { createSelector } from 'reselect';
import { match as fuzzyMatch } from 'fuzzy';

import { RootState } from './index';
import { filteredGroupedRecipes } from './derived/filteredGroupedRecipes';
import { ingredientSplitsByRecipeId } from './derived/ingredientSplitsByRecipeId';
import { filteredGroupedIngredients } from './derived/filteredGroupedIngredients';
import { computeRecipeSimilarity } from './derived/recipeSimilarity';

const selectIngredientsByTag = (state: RootState) => state.ingredients.ingredientsByTag;
const selectGroupedIngredients = (state: RootState) => state.ingredients.groupedIngredients;

const selectRecipesById = (state: RootState) => state.recipes.recipesById;

const selectBaseLiquorFilter = (state: RootState) => state.filters.baseLiquorFilter;
const selectRecipeSearchTerm = (state: RootState) => state.filters.recipeSearchTerm;
const selectIngredientSearchTerm = (state: RootState) => state.filters.ingredientSearchTerm;
const selectIngredientTags = (state: RootState) => state.filters.selectedIngredientTags;
const selectSelectedRecipeList = (state: RootState) => state.filters.selectedRecipeList;

const selectFavoritedRecipeIds = (state: RootState) => state.ui.favoritedRecipeIds;

const selectAlphabeticalRecipes = createSelector(
  selectRecipesById,
  (recipesById) => {
    const alphabeticalRecipeIds = sortBy(
      Object.keys(recipesById),
      recipeId => recipesById[recipeId].sortName
    );

    return alphabeticalRecipeIds.map(recipeId => recipesById[recipeId]);
  }
);

const TODAY = new Date();

export const selectRecipeOfTheHour = createSelector(
  selectRecipesById,
  (recipesById) => {
    const recipes = sortBy(recipesById, r => r.recipeId);
    return recipes[(
      TODAY.getFullYear() * 1000000 +
      TODAY.getMonth() * 10000 +
      TODAY.getDate() * 100 +
      TODAY.getHours()) % recipes.length];
  }
);

export const selectSimilarRecipesByRecipeId = createSelector(
  selectRecipesById,
  selectAlphabeticalRecipes,
  (recipesById, alphabeticalRecipes) => mapValues(recipesById, recipe1 =>
    sortBy(alphabeticalRecipes, recipe2 =>
      recipe1.recipeId === recipe2.recipeId
        ? Infinity
        : -computeRecipeSimilarity(recipe1, recipe2)).slice(0, 5)
  )
)

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

export const selectFuzzyMatchedIngredients = createSelector(
  selectGroupedIngredients,
  selectIngredientSearchTerm,
  (groupedIngredients, searchTerm) =>
    flatten(groupedIngredients.map(g => g.ingredients))
      .map(ingredient => ({
        ingredient,
        bestMatch: ingredient.searchable
          .map(s => fuzzyMatch(searchTerm, s, { caseSensitive: false }))
          .filter(match => !!match)
          .sort((a, b) => b.score - a.score)
          [0]
      }))
      .filter(({ bestMatch }) => !!bestMatch)
      .sort((a, b) => b.bestMatch.score - a.bestMatch.score)
);

export const selectIngredientSplitsByRecipeId = createSelector(
  selectAlphabeticalRecipes,
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
  selectAlphabeticalRecipes,
  selectBaseLiquorFilter,
  selectRecipeSearchTerm,
  selectIngredientTags,
  selectFavoritedRecipeIds,
  selectSelectedRecipeList,
  selectIngredientSplitsByRecipeId,
  (
    ingredientsByTag,
    recipes,
    baseLiquorFilter,
    searchTerm,
    selectedIngredientTags,
    favoritedRecipeIds,
    selectedRecipeList,
    ingredientSplitsByRecipeId,
  ) => filteredGroupedRecipes({
    ingredientsByTag,
    recipes,
    baseLiquorFilter,
    searchTerm,
    selectedIngredientTags,
    favoritedRecipeIds,
    selectedRecipeList,
    ingredientSplitsByRecipeId
  })
);

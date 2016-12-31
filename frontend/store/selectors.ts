import { sortBy, mapValues, flatten } from 'lodash';
import { createSelector, Selector } from 'reselect';
import { match as fuzzyMatch, MatchResult } from 'fuzzy';

import { Ingredient, Recipe } from '../../shared/types';
import { RootState } from './index';
import { filteredGroupedRecipes } from './derived/filteredGroupedRecipes';
import { ingredientSplitsByRecipeId } from './derived/ingredientSplitsByRecipeId';
import { filteredGroupedIngredients } from './derived/filteredGroupedIngredients';
import { computeRecipeSimilarity } from './derived/recipeSimilarity';

export interface FuzzyFilteredItem<T> {
  item: T;
  score: number;
  matchingString: string;
}

interface MatchResultWithItem<T> {
  item: T;
  matchResult: MatchResult;
}

function _cleanUpMatchResults<T>(results: MatchResultWithItem<T>[]): FuzzyFilteredItem<T>[] {
  return results
    .filter(({ matchResult }) => !!matchResult)
    .sort((a, b) => b.matchResult.score - a.matchResult.score)
    .map(r => ({
      item: r.item,
      score: r.matchResult.score,
      matchingString: r.matchResult.rendered
    }));
}

const selectIngredientsByTag = (state: RootState) => state.ingredients.ingredientsByTag;
const selectGroupedIngredients = (state: RootState) => state.ingredients.groupedIngredients;

const selectRecipesById = (state: RootState) => state.recipes.recipesById;

// const selectBaseLiquorFilter = (state: RootState) => state.filters.baseLiquorFilter;
const selectSearchTerm = (state: RootState) => state.filters.searchTerm;
const selectIngredientTags = (state: RootState) => state.filters.selectedIngredientTags;

// const selectFavoritedRecipeIds = (state: RootState) => state.ui.favoritedRecipeIds;

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
  selectSearchTerm,
  (
    groupedIngredients,
    searchTerm
  ) => filteredGroupedIngredients({
    groupedIngredients,
    searchTerm
  })
)

export const selectSearchedIngredients: Selector<RootState, FuzzyFilteredItem<Ingredient>[]> = createSelector(
  selectGroupedIngredients,
  selectSearchTerm,
  (groupedIngredients, searchTerm) =>
    _cleanUpMatchResults(flatten(groupedIngredients.map(g => g.items))
      .map(ingredient => ({
        item: ingredient,
        matchResult: ingredient.searchable
          .map(s => fuzzyMatch(searchTerm, s, { caseSensitive: false }))
          .filter(match => !!match)
          .sort((a, b) => b.score - a.score)
          [0]
      })))
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

export const selectSearchedRecipes: Selector<RootState, FuzzyFilteredItem<Recipe>[]> = createSelector(
  selectAlphabeticalRecipes,
  selectSearchTerm,
  (recipes, searchTerm) => {
    if (!searchTerm) {
      return [];
    } else {
      return _cleanUpMatchResults(recipes
        .map(recipe => ({
          item: recipe,
          matchResult: [ recipe.name, recipe.sortName, recipe.canonicalName ]
            .map(s => fuzzyMatch(searchTerm, s, { caseSensitive: false }))
            .filter(match => !!match)
            .sort((a, b) => b.score - a.score)
            [0]
        })));
    }
  }
);

export const selectIngredientMatchedRecipes = createSelector(
  // selectIngredientsByTag,
  selectAlphabeticalRecipes,
  selectIngredientTags,
  // selectFavoritedRecipeIds,
  selectIngredientSplitsByRecipeId,
  (
    // ingredientsByTag,
    recipes,
    selectedIngredientTags,
    // favoritedRecipeIds,
    ingredientSplitsByRecipeId,
  ) => filteredGroupedRecipes({
    // ingredientsByTag,
    recipes,
    selectedIngredientTags,
    // favoritedRecipeIds,
    ingredientSplitsByRecipeId
  })
);

import { sortBy, mapValues, flatten, chain, groupBy, map } from 'lodash';
import { createSelector, Selector } from 'reselect';
import { match as fuzzyMatch, MatchResult } from 'fuzzy';

import { Ingredient, Recipe } from '../../shared/types';
import { GroupedItems } from '../types';
import { RootState } from './index';
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
const selectSelectedIngredientTags = (state: RootState) => state.filters.selectedIngredientTags;
const selectSearchTerm = (state: RootState) => state.filters.searchTerm;

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

function flattenTree(roots: string[], tree: { [id: string]: string[] }) {
  const flattened: { [id: string]: true } = {};
  let queue = roots.slice();
  while (queue.length) {
    const tag = queue.pop()!;
    if (!flattened[tag]) {
      flattened[tag] = true;
      queue = queue.concat(tree[tag] || []);
    }
  }
  return Object.keys(flattened);
}

const ROOT_INGREDIENT_CATEGORY = '__root__';

const selectIngrdientTree = createSelector(
  selectIngredientsByTag,
  (ingredientsByTag) => chain(ingredientsByTag)
    .map((i: Ingredient) => [ i.generic || ROOT_INGREDIENT_CATEGORY, i.tag ])
    .groupBy(([ generic, _tag ]) => generic)
    .mapValues((pairs: [ string, string ][]) => pairs.map(p => p[1]))
    .value()
)

export const selectAllTransitiveIngredientTags = createSelector(
  selectSelectedIngredientTags,
  selectIngrdientTree,
  flattenTree
);

const selectEachTransitiveIngredientTags = createSelector(
  selectSelectedIngredientTags,
  selectIngrdientTree,
  (selectedIngredientTags, ingredientTree) => selectedIngredientTags.map(t => flattenTree([ t ], ingredientTree))
)

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

// TODO: This is probably slow as fuck.
const selectIngredientMatchedRecipes = createSelector(
  selectAlphabeticalRecipes,
  selectEachTransitiveIngredientTags,
  (recipes, transitiveSelectedIngredientTags) => recipes.filter(r =>
    transitiveSelectedIngredientTags.every(tags =>
      tags.some(t =>
        r.ingredients.some(i => i.tag === t)
      )
    )
  )
)

export const selectGroupedIngredientMatchedRecipes: Selector<RootState, GroupedItems<Recipe>[]>  = createSelector(
  selectIngredientMatchedRecipes,
  (recipes) => sortBy(
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
      (items, groupName) => ({ items, groupName: groupName! })
    ),
    ({ groupName }) => groupName
  )
)

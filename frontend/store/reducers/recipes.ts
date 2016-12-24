import { assign, defaults, omit, without, sortBy } from 'lodash';

import { Recipe } from '../../../shared/types';
import makeReducer from './makeReducer';

function _recomputeDerivedLists(state: RecipesState): RecipesState {
  const alphabeticalRecipeIds = sortBy(
    Object.keys(state.recipesById),
    recipeId => state.recipesById[recipeId].sortName
  );

  return defaults({
    alphabeticalRecipeIds,
    alphabeticalRecipes: alphabeticalRecipeIds.map(recipeId => state.recipesById[recipeId])
  }, state);
};

export interface RecipesState {
  alphabeticalRecipes: Recipe[];
  alphabeticalRecipeIds: string[];
  recipesById: { [recipeId: string]: Recipe };
  customRecipeIds: string[];
}

export const reducer = makeReducer<RecipesState>(assign({
  // TODO: Remove this once bigger refactors are done.
  alphabeticalRecipes: [],
  alphabeticalRecipeIds: [],
  recipesById: {},
  customRecipeIds: []
}, require('../persistence').load().recipes), {
  'recipes-loaded': (state, { recipesById }) => {
    return _recomputeDerivedLists(defaults({ recipesById }, state));
  },

  'saved-recipe': (state, { recipe }) => {
    return _recomputeDerivedLists(defaults({
      customRecipeIds: state.customRecipeIds.concat([recipe.recipeId]),
      recipesById: defaults({
        [recipe.recipeId]: recipe
      }, state.recipesById)
    }, state));
  },

  'delete-recipe': (state, { recipeId }) => {
    return _recomputeDerivedLists(defaults({
      customRecipeIds: without(state.customRecipeIds, recipeId),
      recipesById: omit(state.recipesById, recipeId)
    }, state));
  }
});

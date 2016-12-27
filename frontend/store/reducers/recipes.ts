import { assign, defaults, omit, without } from 'lodash';

import { Recipe } from '../../../shared/types';
import makeReducer from './makeReducer';

export interface RecipesState {
  recipesById: { [recipeId: string]: Recipe };
  customRecipeIds: string[];
}

export const reducer = makeReducer<RecipesState>(assign({
  recipesById: {},
  customRecipeIds: []
}, require('../persistence').load().recipes), {
  'recipes-loaded': (state, { recipesById }) => {
    return defaults({ recipesById }, state);
  },

  'saved-recipe': (state, { recipe }) => {
    return defaults({
      customRecipeIds: state.customRecipeIds.concat([recipe.recipeId]),
      recipesById: defaults({
        [recipe.recipeId]: recipe
      }, state.recipesById)
    }, state);
  },

  'delete-recipe': (state, { recipeId }) => {
    return defaults({
      customRecipeIds: without(state.customRecipeIds, recipeId),
      recipesById: omit(state.recipesById, recipeId)
    }, state);
  }
});

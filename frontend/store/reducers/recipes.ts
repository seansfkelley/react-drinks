import { assign, defaults, omit, without } from 'lodash';

import { Recipe } from '../../../shared/types';
import makeReducer from './makeReducer';
import { Action } from '../ActionType';

export interface RecipesState {
  recipesById: { [recipeId: string]: Recipe };
  customRecipeIds: string[];
}

export const reducer = makeReducer<RecipesState>(assign({
  recipesById: {},
  customRecipeIds: []
}, require('../persistence').load().recipes), {
  'set-recipes-by-id': (state, action: Action<{ [recipeId: string]: Recipe }>) => {
    return defaults({ recipesById: action.payload }, state);
  },

  'delete-recipe': (state, action: Action<string>) => {
    const recipeId = action.payload!;
    return defaults({
      customRecipeIds: without(state.customRecipeIds, recipeId),
      recipesById: omit(state.recipesById, recipeId)
    }, state);
  }
});

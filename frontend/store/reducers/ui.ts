import { assign, defaults, union, without } from 'lodash';

import makeReducer from './makeReducer';
import { load } from '../persistence';
import { Action } from '../ActionType';
import { SearchTabType } from '../../types';

export interface UiState {
  errorMessage?: string;
  recipeViewingIndex: number;
  currentlyViewedRecipeIds: string[];
  favoritedRecipeIds: string[];
  searchTabType: SearchTabType;
  currentIngredientInfo?: string;
  showingRecipeViewer: boolean;
  showingRecipeEditor: boolean;
}

export const reducer = makeReducer<UiState>(assign({
  errorMessage: undefined,
  recipeViewingIndex: 0,
  currentlyViewedRecipeIds: [],
  favoritedRecipeIds: [],
  searchTabType: 'ingredients' as SearchTabType, // TODO: Why does this need a cast??
  currentIngredientInfo: undefined,
  showingRecipeViewer: false,
  showingRecipeEditor: false,
}, load().ui), {
  'set-recipe-viewing-index': (state, action: Action<number>) => defaults({
    recipeViewingIndex: action.payload
  }, state),

  'favorite-recipe': (state, action: Action<string>) => defaults({
    favoritedRecipeIds: union(state.favoritedRecipeIds, [ action.payload ])
  }, state),

  'unfavorite-recipe': (state, action: Action<string>) => defaults({
    favoritedRecipeIds: without(state.favoritedRecipeIds, action.payload)
  }, state),

  'show-recipe-viewer': (state, action: Action<{ index: number, recipeIds: string[] }>) => defaults({
      showingRecipeViewer: true,
      recipeViewingIndex: action.payload.index,
      currentlyViewedRecipeIds: action.payload.recipeIds
    }, state),

  'hide-recipe-viewer': (state) => defaults({
      showingRecipeViewer: false,
      recipeViewingIndex: 0,
      currentlyViewedRecipeIds: []
    }, state),

  'show-recipe-editor': (state) => defaults({
    showingRecipeEditor: true
  }, state),

  'hide-recipe-editor': (state) => defaults({
    showingRecipeEditor: false
  }, state),

  'error-message': (state, action: Action<string>) => defaults({
    errorMessage: action.payload
  }, state),

  'show-ingredient-info': (state, action: Action<string>) => defaults({
    currentIngredientInfo: action.payload
  }, state),

  'hide-ingredient-info': (state) => defaults({
    currentIngredientInfo: null
  }, state)
});

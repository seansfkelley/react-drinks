import { assign, defaults, union, without, indexOf, clone } from 'lodash';

import makeReducer from './makeReducer';
import { load } from '../persistence';
import { Action } from '../ActionType';

export interface UiState {
  errorMessage?: string;
  recipeViewingIndex: number;
  currentlyViewedRecipeIds: string[];
  favoritedRecipeIds: string[];
  showingRecipeViewer: boolean;
  showingRecipeEditor: boolean;
  showingSidebar: boolean;
  showingListSelector: boolean;
}

export const reducer = makeReducer<UiState>(assign({
  errorMessage: undefined,
  recipeViewingIndex: 0,
  currentlyViewedRecipeIds: [],
  favoritedRecipeIds: [],

  showingRecipeViewer: false,
  showingRecipeEditor: false,
  showingSidebar: false,
  showingListSelector: false
}, load().ui), {
  'rewrite-recipe-id': (state, action: Action<{ from: string, to: string }>) => {
    const { from, to } = action.payload!;
    let { currentlyViewedRecipeIds, favoritedRecipeIds } = state;

    let i = indexOf(currentlyViewedRecipeIds, from);
    if (i !== -1) {
      currentlyViewedRecipeIds = clone(currentlyViewedRecipeIds);
      currentlyViewedRecipeIds[i] = to;
    }

    i = indexOf(favoritedRecipeIds, from);
    if (i !== -1) {
      favoritedRecipeIds = clone(favoritedRecipeIds);
      favoritedRecipeIds[i] = to;
    }

    return defaults({ currentlyViewedRecipeIds, favoritedRecipeIds }, state);
  },

  'set-recipe-viewing-index': (state, action: Action<number>) => {
    const index = action.payload;
    return defaults({ recipeViewingIndex: index }, state);
  },

  'favorite-recipe': (state, action: Action<string>) => {
    const recipeId = action.payload;
    return defaults({ favoritedRecipeIds: union(state.favoritedRecipeIds, [recipeId]) }, state);
  },

  'unfavorite-recipe': (state, action: Action<string>) => {
    const recipeId = action.payload;
    return defaults({ favoritedRecipeIds: without(state.favoritedRecipeIds, recipeId) }, state);
  },

  'show-recipe-viewer': (state, action: Action<{ index: number, recipeIds: string[] }>) => {
    const { index, recipeIds } = action.payload!;
    return defaults({
      showingRecipeViewer: true,
      recipeViewingIndex: index,
      currentlyViewedRecipeIds: recipeIds
    }, state);
  },

  'hide-recipe-viewer': (state) => {
    return defaults({
      showingRecipeViewer: false,
      recipeViewingIndex: 0,
      currentlyViewedRecipeIds: []
    }, state);
  },

  'show-recipe-editor': (state) => {
    return defaults({ showingRecipeEditor: true }, state);
  },

  'hide-recipe-editor': (state) => {
    return defaults({ showingRecipeEditor: false }, state);
  },

  'show-sidebar': (state) => {
    return defaults({ showingSidebar: true }, state);
  },

  'hide-sidebar': (state) => {
    return defaults({ showingSidebar: false }, state);
  },

  'show-list-selector': (state) => {
    return defaults({ showingListSelector: true }, state);
  },

  'hide-list-selector': (state) => {
    return defaults({ showingListSelector: false }, state);
  },

  'error-message': (state, action: Action<string>) => {
    return defaults({ errorMessage: action.payload }, state);
  }
});

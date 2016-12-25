import { Store } from 'redux';
import { mapValues, debounce, pick, pickBy, once, omitBy, isUndefined } from 'lodash';
import * as log from 'loglevel';

import { RootState } from '.';

const ONE_MINUTE_MS = 1000 * 60;
const LOCALSTORAGE_KEY = 'drinks-app-persistence';
const PERSISTENCE_SPEC: { [k1 in keyof RootState]?: { [k2 in keyof RootState[k1]]?: number } } = {
  filters: {
    recipeSearchTerm: ONE_MINUTE_MS * 5,
    baseLiquorFilter: ONE_MINUTE_MS * 15,
    selectedIngredientTags: Infinity,
    selectedRecipeList: ONE_MINUTE_MS * 60
  },
  recipes: {
    customRecipeIds: Infinity
  },
  ui: {
    errorMessage: 0,
    recipeViewingIndex: ONE_MINUTE_MS * 5,
    currentlyViewedRecipeIds: ONE_MINUTE_MS * 5,
    favoritedRecipeIds: Infinity,
    showingRecipeViewer: ONE_MINUTE_MS * 5,
    showingRecipeEditor: Infinity,
    showingSidebar: ONE_MINUTE_MS * 5,
    showingListSelector: ONE_MINUTE_MS
  },
  editableRecipe: {
    originalRecipeId: Infinity,
    currentPage: Infinity,
    name: Infinity,
    ingredients: Infinity,
    instructions: Infinity,
    notes: Infinity,
    base: Infinity,
    saving: 0
  }
};

export function watch(store: Store<RootState>) {
  store.subscribe(debounce(() => {
    const state = store.getState();

    const data = mapValues(PERSISTENCE_SPEC, (spec, storeName) => pick((state as any)[storeName!], Object.keys(spec)));

    const timestamp = Date.now();
    localStorage[LOCALSTORAGE_KEY] = JSON.stringify({ data, timestamp });

    return log.debug(`persisted data at t=${timestamp}`);
  }, 1000));
}

export const load = once((): Partial<RootState> => {
  const { data, timestamp } = JSON.parse(localStorage[LOCALSTORAGE_KEY] != null ? localStorage[LOCALSTORAGE_KEY] : '{}');

  if (data == null) {
    // Legacy version.
    const ui = JSON.parse(localStorage['drinks-app-ui'] != null ? localStorage['drinks-app-ui'] : '{}');
    const recipes = JSON.parse(localStorage['drinks-app-recipes'] != null ? localStorage['drinks-app-recipes'] : '{}');
    const ingredients = JSON.parse(localStorage['drinks-app-ingredients'] != null ? localStorage['drinks-app-ingredients'] : '{}');

    return mapValues({
      filters: {
        recipeSearchTerm: recipes.searchTerm,
        baseLiquorFilter: ui.baseLiquorFilter,
        selectedIngredientTags: ingredients.selectedIngredientTags
      },
      recipes: {
        customRecipes: recipes.customRecipes
      },
      ui: {
        recipeViewingIndex: ui.recipeViewingIndex
      }
    }, store => omitBy(store, isUndefined));
  } else {
    const elapsedTime = Date.now() - +(timestamp != null ? timestamp : 0);
    return mapValues(PERSISTENCE_SPEC, (spec, storeName) => {
      return omitBy(
        pickBy(
          pick(
            data[storeName!],
            Object.keys(spec)
          ),
          (_value, key) => elapsedTime < (spec as any)[key!]
        ),
        isUndefined
      );
    });
  }
});

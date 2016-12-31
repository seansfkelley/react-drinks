import { Store } from 'redux';
import { mapValues, debounce, pick, pickBy, once, omitBy, isUndefined } from 'lodash';
import * as log from 'loglevel';

import { RootState } from '.';

type PersistenceSpec = { [k1 in keyof RootState]?: { [k2 in keyof RootState[k1]]?: number } };
type RootStateSubset = { [k1 in keyof RootState]?: { [k2 in keyof RootState[k1]]?: RootState[k1][k2] }};

const PERSISTENCE_VERSION = 0;

interface SerializedData {
  data: RootStateSubset;
  schemaVersion: number;
  timestamp: number;
}

const ONE_MINUTE_MS = 1000 * 60;
const LOCALSTORAGE_KEY = 'drinks-app-persistence';
const PERSISTENCE_SPEC: PersistenceSpec = {
  filters: {
    searchTerm: ONE_MINUTE_MS * 5,
    // baseLiquorFilter: ONE_MINUTE_MS * 15,
    selectedIngredientTags: Infinity,
  },
  recipes: {
    customRecipeIds: Infinity
  },
  ui: {
    errorMessage: 0,
    recipeViewingIndex: ONE_MINUTE_MS * 5,
    currentlyViewedRecipeIds: ONE_MINUTE_MS * 5,
    currentIngredientInfo: 0,
    favoritedRecipeIds: Infinity,
    showingRecipeViewer: ONE_MINUTE_MS * 5,
    showingRecipeEditor: Infinity
  }
};

export function watch(store: Store<RootState>) {
  store.subscribe(debounce(() => {
    const state = store.getState();

    const serializedData: SerializedData = {
      data: mapValues(PERSISTENCE_SPEC, (spec, storeName: keyof PersistenceSpec) => pick(state[storeName!], Object.keys(spec))),
      schemaVersion: PERSISTENCE_VERSION,
      timestamp: Date.now()
    };

    localStorage[LOCALSTORAGE_KEY] = JSON.stringify(serializedData);

    log.debug(`persisted data at t=${serializedData.timestamp} (${new Date(serializedData.timestamp).toString()})`);
  }, 1000));
}

export const load = once((): Partial<RootState> => {
  const { data, schemaVersion, timestamp } = JSON.parse(localStorage[LOCALSTORAGE_KEY] || '{}') as SerializedData;

  if (data == null) {
    log.info('loading legacy-shaped data from localStorage...');

    // Extra-legacy version.
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
  } else if (schemaVersion === 0 || schemaVersion == null) {
    log.info(`will load data from localStorage with schema version ${schemaVersion}`);

    const elapsedTime = Date.now() - +(timestamp != null ? timestamp : 0);
    return mapValues(PERSISTENCE_SPEC, (spec, storeName: keyof PersistenceSpec) => {
      return omitBy(
        pickBy(
          pick(
            data[storeName]!,
            Object.keys(spec)
          ),
          (_value, key) => elapsedTime < (spec as any)[key!]
        ),
        isUndefined
      );
    });
  } else {
    log.error(`loading from localStorage failed; unknown schema version ${schemaVersion}; will return empty object`);
    return {};
  }
});

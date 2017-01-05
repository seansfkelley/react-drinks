import { Store } from 'redux';
import { mapValues, debounce, pick, pickBy, once, omitBy, isUndefined, isPlainObject } from 'lodash';
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

export const load = once((): RootStateSubset => {
  const { data, schemaVersion, timestamp } = JSON.parse(localStorage[LOCALSTORAGE_KEY] || '{}') as SerializedData;

  if (data == null) {
    log.info('no existing localStorage data was found; will return empty object');
    return {};
  } else if (schemaVersion === 0 || schemaVersion == null) {
    log.info(`will load data from localStorage with schema version ${schemaVersion}`);

    const elapsedTime = Date.now() - +(timestamp != null ? timestamp : 0);
    const parsedState: RootStateSubset = mapValues(PERSISTENCE_SPEC, (spec, storeName: keyof PersistenceSpec) => {
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

    // This is an old format; ignore it.
    if (parsedState.filters && isPlainObject(parsedState.filters.selectedIngredientTags)) {
      parsedState.filters.selectedIngredientTags = [];
    }

    return parsedState;
  } else {
    log.error(`loading from localStorage failed; unknown schema version ${schemaVersion}; will return empty object`);
    return {};
  }
});

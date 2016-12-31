export type ActionType =
  'set-search-term' |
  'set-selected-ingredient-tags' |
  'set-ingredients' |
  'set-recipes-by-id' |
  'hide-recipe-viewer' |
  'hide-recipe-editor' |
  'hide-ingredient-info' |
  'show-recipe-viewer' |
  'delete-recipe' |
  'set-recipe-viewing-index' |
  'seed-recipe-editor' |
  'show-recipe-editor' |
  'favorite-recipe' |
  'unfavorite-recipe' |
  'set-base-liquor-filter' |
  'show-recipe-editor' |
  'show-ingredient-info' |
  'error-message' |
  '--dummy-event-to-trigger-persistence--';

export type Action<T> = {
  type: ActionType;
  payload: T;
};

export type ActionType =
  'set-ingredients' |
  'set-recipes-by-id' |
  'hide-recipe-viewer' |
  'hide-sidebar' |
  'hide-recipe-editor' |
  'hide-list-selector' |
  'hide-ingredient-info' |
  'show-recipe-viewer' |
  'delete-recipe' |
  'set-selected-recipe-list' |
  'set-selected-ingredient-tags' |
  'set-recipe-search-term' |
  'set-ingredient-search-term' |
  'set-recipe-viewing-index' |
  'seed-recipe-editor' |
  'show-recipe-editor' |
  'favorite-recipe' |
  'unfavorite-recipe' |
  'set-base-liquor-filter' |
  'show-sidebar' |
  'show-list-selector' |
  'show-recipe-editor' |
  'show-ingredient-info' |
  'error-message' |
  '--dummy-event-to-trigger-persistence--';

export type Action<T> = {
  type: ActionType;
  payload: T;
};

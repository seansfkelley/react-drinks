export type ActionType =
  '--dummy-event-to-trigger-persistence--' |
  'delete-recipe' |
  'error-message' |
  'hide-ingredient-info' |
  'hide-recipe-editor' |
  'hide-recipe-viewer' |
  'seed-recipe-editor' |
  'set-ingredients' |
  'set-recipe-favorite' |
  'set-recipe-viewing-index' |
  'set-recipes-by-id' |
  'set-search-term' |
  'set-selected-ingredient-tags' |
  'show-ingredient-info' |
  'show-recipe-editor' |
  'show-recipe-viewer';

export type Action<T> = {
  type: ActionType;
  payload: T;
};

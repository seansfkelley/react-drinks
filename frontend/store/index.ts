import { applyMiddleware, createStore, combineReducers } from 'redux';
import * as createLogger from 'redux-logger';

import { reducer as reduceUi, UiState } from './reducers/ui';
import { reducer as reduceFilters, FiltersState } from './reducers/filters';
import { reducer as reduceIngredients, IngredientsState } from './reducers/ingredients';
import { reducer as reduceRecipes, RecipesState } from './reducers/recipes';

export interface RootState {
  ui: UiState;
  filters: FiltersState;
  ingredients: IngredientsState;
  recipes: RecipesState;
}

const rootReducer = combineReducers({
  ui: reduceUi,
  filters: reduceFilters,
  ingredients: reduceIngredients,
  recipes: reduceRecipes
});

export const store = applyMiddleware(createLogger({ collapsed: true }))(createStore)(rootReducer);

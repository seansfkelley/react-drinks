import { applyMiddleware, createStore, combineReducers } from 'redux';
import * as ReduxThunk from 'redux-thunk';

import { reducer as reduceUi, UiState } from './reducers/ui';
import { reducer as reduceFilters, FiltersState } from './reducers/filters';
import { reducer as reduceIngredients, IngredientsState } from './reducers/ingredients';
import { reducer as reduceRecipes, RecipesState } from './reducers/recipes';
import { reducer as reduceEditableRecipe, EditableRecipeState } from './reducers/editableRecipe';

export interface RootState {
  ui: UiState;
  filters: FiltersState;
  ingredients: IngredientsState;
  recipes: RecipesState;
  editableRecipe: EditableRecipeState;
}

const rootReducer = combineReducers({
  ui: reduceUi,
  filters: reduceFilters,
  ingredients: reduceIngredients,
  recipes: reduceRecipes,
  editableRecipe: reduceEditableRecipe
});

export const store = applyMiddleware(ReduxThunk)(createStore)(rootReducer);

import { Ingredient, Recipe, IngredientGroupMeta } from '../../shared/types';
import { RecipeListType } from '../types';
import { Action, ActionType } from './ActionType';

function createNullaryActionCreator(type: ActionType) {
  return function(): Action<void> {
    return { type, payload: undefined };
  }
}

function createActionCreator<P>(type: ActionType) {
  return function(payload: P): Action<P> {
    return { type, payload };
  }
}

export const hideRecipeViewer = createNullaryActionCreator('hide-recipe-viewer');
export const hideSidebar = createNullaryActionCreator('hide-sidebar');
export const hideRecipeEditor = createNullaryActionCreator('hide-recipe-editor');
export const hideListSelector = createNullaryActionCreator('hide-list-selector');
export const hideIngredientInfo = createNullaryActionCreator('hide-ingredient-info');
export const showRecipeViewer = createActionCreator<{ recipeIds: string[], index: number  }>('show-recipe-viewer');
export const deleteRecipe = createActionCreator<string>('delete-recipe');
export const setSelectedRecipeList = createActionCreator<RecipeListType>('set-selected-recipe-list');
export const setSelectedIngredientTags = createActionCreator<string[]>('set-selected-ingredient-tags');
export const setRecipeSearchTerm = createActionCreator<string>('set-recipe-search-term');
export const setIngredientSearchTerm = createActionCreator<string>('set-ingredient-search-term');
export const setRecipeViewingIndex = createActionCreator<number>('set-recipe-viewing-index');
export const seedRecipeEditor = createActionCreator<Recipe>('seed-recipe-editor');
export const showRecipeEditor = createNullaryActionCreator('show-recipe-editor');
export const favoriteRecipe = createActionCreator<string>('favorite-recipe');
export const unfavoriteRecipe = createActionCreator<string>('unfavorite-recipe');
export const setBaseLiquorFilter = createActionCreator<string>('set-base-liquor-filter');
export const showSidebar = createNullaryActionCreator('show-sidebar');
export const showListSelector = createNullaryActionCreator('show-list-selector');
export const showIngredientInfo = createActionCreator<string>('show-ingredient-info');
export const initializeNewRecipe = createNullaryActionCreator('show-recipe-editor');
export const setErrorMessage = createActionCreator<string>('error-message');
export const setIngredients = createActionCreator<{ ingredients: Ingredient[], groups: IngredientGroupMeta[] }>('set-ingredients');
export const setRecipesById = createActionCreator<{ [recipeId: string]: Recipe }>('set-recipes-by-id');
// The idea is to refresh the timestamps, even if the user doesn't interact. Opening the app
// should be sufficient interaction to reset the timers on all the expirable pieces of state.
export const noopTriggerPersistence = createNullaryActionCreator('--dummy-event-to-trigger-persistence--');

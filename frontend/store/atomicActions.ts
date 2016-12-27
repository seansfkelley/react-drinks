import { Ingredient, Recipe, IngredientGroupMeta } from '../../shared/types';
import { RecipeListType } from '../types';
import { Action } from './ActionType';

export function hideRecipeViewer(): Action<void> {
  return {
    type: 'hide-recipe-viewer'
  };
}

export function hideSidebar(): Action<void> {
  return {
    type: 'hide-sidebar'
  };
}

export function hideRecipeEditor(): Action<void> {
  return {
    type: 'hide-recipe-editor'
  };
}

export function hideListSelector(): Action<void> {
  return {
    type: 'hide-list-selector'
  };
}

export function showRecipeViewer(recipeIds: string[], index: number): Action<{ recipeIds: string[], index: number  }> {
  return {
    type: 'show-recipe-viewer',
    payload: {
      recipeIds,
      index
    }
  }
}

export function deleteRecipe(recipeId: string): Action<string> {
  return {
    type: 'delete-recipe',
    payload: recipeId
  };
}

export function setSelectedRecipeList(listType: RecipeListType): Action<RecipeListType> {
  return {
    type: 'set-selected-recipe-list',
    payload: listType
  };
}

export function setSelectedIngredientTags(tags: { [tag: string]: any }): Action<{ [tag: string]: any }> {
  return {
    type: 'set-selected-ingredient-tags',
    payload: tags
  };
}

export function setRecipeSearchTerm(searchTerm: string): Action<string> {
  return {
    type: 'set-recipe-search-term',
    payload: searchTerm
  };
}

export function setIngredientSearchTerm(searchTerm: string): Action<string> {
  return {
    type: 'set-ingredient-search-term',
    payload: searchTerm
  };
}

export function setRecipeViewingIndex(index: number): Action<number> {
  return {
    type: 'set-recipe-viewing-index',
    payload: index
  };
}

export function seedRecipeEditor(recipe: Recipe): Action<Recipe> {
  return {
    type: 'seed-recipe-editor',
    payload: recipe
  };
}

export function showRecipeEditor(): Action<void> {
  return {
    type: 'show-recipe-editor'
  };
}

export function favoriteRecipe(recipeId: string): Action<string> {
  return {
    type: 'favorite-recipe',
    payload: recipeId
  };
}

export function unfavoriteRecipe(recipeId: string): Action<string> {
  return {
    type: 'unfavorite-recipe',
    payload: recipeId
  };
}

export function setBaseLiquorFilter(baseLiquorType: string): Action<string> {
  return {
    type: 'set-base-liquor-filter',
    payload: baseLiquorType
  };
}

export function showSidebar(): Action<void> {
  return {
    type: 'show-sidebar'
  };
}

export function showListSelector(): Action<void> {
  return {
    type: 'show-list-selector'
  };
}

export function initializeNewRecipe(): Action<void> {
  return {
    type: 'show-recipe-editor'
  };
}

export function setErrorMessage(errorMessage?: string): Action<string> {
  return {
    type: 'error-message',
    payload: errorMessage
  };
}

export function setIngredients(ingredients: { ingredients: Ingredient[], groups: IngredientGroupMeta[] }): Action<{ ingredients: Ingredient[], groups: IngredientGroupMeta[] }> {
  return {
    type: 'set-ingredients',
    payload: ingredients
  };
}

export function setRecipesById(recipesById: { [recipeId: string]: Recipe }): Action<{ [recipeId: string]: Recipe }> {
  return {
    type: 'set-recipes-by-id',
    payload: recipesById
  };
}

// The idea is to refresh the timestamps, even if the user doesn't interact. Opening the app
// should be sufficient interaction to reset the timers on all the expirable pieces of state.
export function noopTriggerPersistence(): Action<void> {
  return {
    type: '--dummy-event-to-trigger-persistence--'
  };
}

import { Recipe } from '../../shared/types';
import { RecipeListType } from '../types';

export function hideRecipeViewer() {
  return {
    type: 'hide-recipe-viewer'
  };
}

export function hideSidebar() {
  return {
    type: 'hide-sidebar'
  };
}

export function hideRecipeEditor() {
  return {
    type: 'hide-recipe-editor'
  };
}

export function hideListSelector() {
  return {
    type: 'hide-list-selector'
  };
}

export function showRecipeViewer(recipeIds: string[], index: number) {
  return {
    type: 'show-recipe-viewer',
    recipeIds,
    index
  }
}

export function deleteRecipe(recipeId: string) {
  return {
    type: 'delete-recipe',
    recipeId
  };
}

export function setSelectedRecipeList(listType: RecipeListType) {
  return {
    type: 'set-selected-recipe-list',
    listType
  };
}

export function setSelectedIngredientTags(tags: { [tag: string]: any }) {
  return {
    type: 'set-selected-ingredient-tags',
    tags
  };
}

export function setRecipeSearchTerm(searchTerm: string) {
  return {
    type: 'set-recipe-search-term',
    searchTerm
  };
}

export function setIngredientSearchTerm(searchTerm: string) {
  return {
    type: 'set-ingredient-search-term',
    searchTerm
  };
}

export function setRecipeViewingIndex(index: number) {
  return {
    type: 'set-recipe-viewing-index',
    index
  };
}

export function seedRecipeEditor(recipe: Recipe) {
  return {
    type: 'seed-recipe-editor',
    recipe
  };
}

export function showRecipeEditor() {
  return {
    type: 'show-recipe-editor'
  };
}

export function favoriteRecipe(recipeId: string) {
  return {
    type: 'favorite-recipe',
    recipeId
  };
}

export function unfavoriteRecipe(recipeId: string) {
  return {
    type: 'unfavorite-recipe',
    recipeId
  };
}

export function setBaseLiquorFilter(baseLiquorType: string) {
  return {
    type: 'set-base-liquor-filter',
    filter: baseLiquorType
  };
}

export function showSidebar() {
  return {
    type: 'show-sidebar'
  };
}

export function showListSelector() {
  return {
    type: 'show-list-selector'
  };
}

export function initializeNewRecipe() {
  return {
    type: 'show-recipe-editor'
  };
}

import { Ingredient, Recipe } from '../shared/types';

export type EditableRecipePageType = string & { __editableRecipePageTypeBrand: any };
export const EditableRecipePageType = {
  NAME: 'name' as EditableRecipePageType,
  INGREDIENTS: 'ingredients' as EditableRecipePageType,
  TEXT: 'text' as EditableRecipePageType,
  BASE: 'base' as EditableRecipePageType,
  PREVIEW: 'preview' as EditableRecipePageType
};

export interface GroupedIngredients {
  name: string;
  ingredients: Ingredient[];
}

export interface GroupedRecipes {
  key: string;
  recipes: Recipe[];
}

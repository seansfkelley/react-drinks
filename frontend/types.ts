export type EditableRecipePageType = 'name' | 'ingredients' | 'text' | 'base' | 'preview';
export const EditableRecipePageType = {
  NAME: 'name' as EditableRecipePageType,
  INGREDIENTS: 'ingredients' as EditableRecipePageType,
  TEXT: 'text' as EditableRecipePageType,
  BASE: 'base' as EditableRecipePageType,
  PREVIEW: 'preview' as EditableRecipePageType
};

export type RecipeListType = 'all' | 'mixable' | 'favorites' | 'custom';
export const RecipeListType = {
  ALL: 'all' as RecipeListType,
  MIXABLE: 'mixable' as RecipeListType,
  FAVORITES: 'favorites' as RecipeListType,
  CUSTOM: 'custom' as RecipeListType
};

export type SearchTabType = 'ingredients' | 'recipes';

export interface GroupedItems<T> {
  groupName: string;
  items: T[];
}

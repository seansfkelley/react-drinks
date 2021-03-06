export interface DisplayIngredient {
  tag?: string;
  displayIngredient: string;
  displayAmount?: string;
  displayUnit?: string;
}

export interface Ingredient {
  display: string;
  group: string;
  tangible: boolean;
  // TODO: Replace tag with ingredientId.
  tag: string;
  generic?: string;
  difficulty: 'easy' | 'medium' | 'hard';
  searchable: string[];
}

export interface IngredientGroupMeta {
  type: string;
  display: string;
}

export interface DbRecipe {
  name: string;
  ingredients: DisplayIngredient[];
  instructions: string;
  notes?: string;
  source?: string;
  url?: string;
  base: string | string[];
  canonicalName: string;
  sortName: string;
  isCustom?: boolean;
}

export interface Recipe extends DbRecipe {
  recipeId: string;
}

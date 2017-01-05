export interface DisplayIngredient {
  tag?: string;
  displayIngredient: string;
  displayAmount?: string;
  displayUnit?: string;
}

export interface Ingredient {
  display: string;
  // TODO: Replace tag with ingredientId.
  tag: string;
  generic?: string;
  searchable: string[];
}

export interface DbRecipe {
  name: string;
  ingredients: DisplayIngredient[];
  instructions: string;
  notes?: string;
  source?: string;
  url?: string;
  canonicalName: string;
  sortName: string;
}

export interface Recipe extends DbRecipe {
  recipeId: string;
}

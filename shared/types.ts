// TODO: What other fields are on these types?

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
  tag: string;
  generic?: string;
  difficulty: 'easy' | 'medium' | 'hard';
  searchable: string[];
}

export interface IngredientGroup {
  type: string;
  display: string;
}

export interface Recipe {
  name: string;
  ingredients: DisplayIngredient[];
  instructions: string;
  notes?: string;
  source?: string;
  url?: string;
  base: string | string[];
  canonicalName: string;
  sortName: string;
}

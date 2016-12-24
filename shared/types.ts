// TODO: What other fields are on these types?

export interface Ingredient {
  display: string;
  tag: string;
  searchable: string[];
  tangible: boolean;
}

export interface Recipe {
  name: string;
  canonicalName: string;
  sortName: string;
  base: string[];
}

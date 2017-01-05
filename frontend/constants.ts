import { RecipeListType } from './types';

export const ORDERED_RECIPE_LIST_TYPES = [
  RecipeListType.ALL,
  RecipeListType.MIXABLE,
  RecipeListType.FAVORITES,
  RecipeListType.CUSTOM
];

export const RECIPE_LIST_NAMES = {
  [RecipeListType.ALL]: 'All Drinks',
  [RecipeListType.MIXABLE]: 'Mixable Drinks',
  [RecipeListType.FAVORITES]: 'Favorites',
  [RecipeListType.CUSTOM]: 'Custom Drinks'
};

export const BASIC_LIQUOR_TAGS = ['gin', 'vodka', 'whiskey', 'rum', 'brandy', 'agave spirits', 'wine'];

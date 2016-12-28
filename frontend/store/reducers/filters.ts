import { assign, defaults } from 'lodash';

import makeReducer from './makeReducer';
import { load } from '../persistence';
import { ANY_BASE_LIQUOR } from '../../../shared/definitions';
import { ORDERED_RECIPE_LIST_TYPES } from '../../constants';
import { RecipeListType } from '../../types';
import { Action } from '../ActionType';

export interface FiltersState {
  recipeSearchTerm: string;
  ingredientSearchTerm: string;
  selectedIngredientTags: string[];
  baseLiquorFilter: string;
  selectedRecipeList: RecipeListType;
}

export const reducer = makeReducer<FiltersState>(assign({
  recipeSearchTerm: '',
  ingredientSearchTerm: '',
  selectedIngredientTags: [],
  baseLiquorFilter: ANY_BASE_LIQUOR,
  selectedRecipeList: ORDERED_RECIPE_LIST_TYPES[0]
}, load().filters), {
  'set-recipe-search-term': (state, action: Action<string>) => {
    return defaults({ recipeSearchTerm: action.payload }, state);
  },

  'set-ingredient-search-term': (state, action: Action<string>) => {
    return defaults({ ingredientSearchTerm: action.payload }, state);
  },

  'set-selected-ingredient-tags': (state, action: Action<{ [tag: string]: any }>) => {
    return defaults({ selectedIngredientTags: action.payload }, state);
  },

  'set-base-liquor-filter': (state, action: Action<string>) => {
    return defaults({ baseLiquorFilter: action.payload }, state);
  },

  'set-selected-recipe-list': (state, action: Action<RecipeListType>) => {
    return defaults({ selectedRecipeList: action.payload }, state);
  }
});

import { assign, defaults } from 'lodash';

import makeReducer from './makeReducer';
import { load } from '../persistence';
import { ANY_BASE_LIQUOR, RECIPE_LIST_TYPES } from '../../../shared/definitions';

export interface FiltersState {
  recipeSearchTerm: string;
  ingredientSearchTerm: string;
  selectedIngredientTags: { [tag: string]: any },
  baseLiquorFilter: string;
  selectedRecipeList: string;
}

export const reducer = makeReducer<FiltersState>(assign({
  recipeSearchTerm: '',
  ingredientSearchTerm: '',
  selectedIngredientTags: {},
  baseLiquorFilter: ANY_BASE_LIQUOR,
  selectedRecipeList: RECIPE_LIST_TYPES[0]
}, load().filters), {
  'set-recipe-search-term': (state, { searchTerm }) => {
    return defaults({ recipeSearchTerm: searchTerm }, state);
  },

  'set-ingredient-search-term': (state, { searchTerm }) => {
    return defaults({ ingredientSearchTerm: searchTerm }, state);
  },

  'set-selected-ingredient-tags': (state, { tags }) => {
    return defaults({ selectedIngredientTags: tags }, state);
  },

  'set-base-liquor-filter': (state, { filter }) => {
    return defaults({ baseLiquorFilter: filter }, state);
  },

  'set-selected-recipe-list': (state, { listType }) => {
    return defaults({ selectedRecipeList: listType }, state);
  }
});

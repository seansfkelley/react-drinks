import { assign, defaults } from 'lodash';

import makeReducer from './makeReducer';
import { load } from '../persistence';
import { Action } from '../ActionType';

export interface FiltersState {
  searchTerm: string;
  selectedIngredientTags: string[];
  // baseLiquorFilter: string; // TODO: Should I bring this back?
}

export const reducer = makeReducer<FiltersState>(assign({
  searchTerm: '',
  selectedIngredientTags: []
}, load().filters), {
  'set-search-term': (state, action: Action<string>) => {
    return defaults({ searchTerm: action.payload }, state);
  },

  'set-selected-ingredient-tags': (state, action: Action<{ [tag: string]: any }>) => {
    return defaults({ selectedIngredientTags: action.payload }, state);
  },

  // 'set-base-liquor-filter': (state, action: Action<string>) => {
  //   return defaults({ baseLiquorFilter: action.payload }, state);
  // }
});

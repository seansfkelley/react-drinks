import { assign, keyBy } from 'lodash';

import makeReducer from './makeReducer';
import { load } from '../persistence';
import { Ingredient } from '../../../shared/types';
import { Action } from '../ActionType';

export interface IngredientsState {
  ingredientsByTag: { [tag: string]: Ingredient };
}

export const reducer = makeReducer<IngredientsState>(assign({
  ingredientsByTag: {}
}, load().ingredients), {
  'set-ingredients': (_state, action: Action<Ingredient[]>) => {
    // We don't use state, this is a set-once kind of deal.
    return {
      ingredientsByTag: keyBy(action.payload, i => i.tag)
    };
  }
});

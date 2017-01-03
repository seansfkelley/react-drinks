import { assign } from 'lodash';
import * as log from 'loglevel';

import makeReducer from './makeReducer';
import { load } from '../persistence';
import { Ingredient } from '../../../shared/types';
import { normalizeIngredient } from '../../../shared/normalization';
import { Action } from '../ActionType';

function _computeIngredientsByTag(ingredients: Ingredient[]) {
  const ingredientsByTag = ingredients
    .reduce((obj, i) =>{
      obj[i.tag] = i;
      return obj;
    }, {} as { [tag: string]: Ingredient });

  ingredients.forEach(i => {
    if (i.generic != null && ingredientsByTag[i.generic] == null) {
      log.trace(`ingredient ${i.tag} refers to unknown generic ${i.generic}; inferring generic`);
      ingredientsByTag[i.generic] = normalizeIngredient({
        tag: i.generic,
        display: `[inferred] ${ i.generic }`
      });
    }
  });

  return ingredientsByTag;
};

export interface IngredientsState {
  ingredientsByTag: { [tag: string]: Ingredient };
}

export const reducer = makeReducer<IngredientsState>(assign({
  ingredientsByTag: {}
}, load().ingredients), {
  'set-ingredients': (_state, action: Action<Ingredient[]>) => {
    // We don't use state, this is a set-once kind of deal.
    return {
      ingredientsByTag: _computeIngredientsByTag(action.payload)
    };
  }
});

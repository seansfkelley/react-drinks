import { assign, sortBy, groupBy, map, findIndex } from 'lodash';
import * as log from 'loglevel';

import makeReducer from './makeReducer';
import { load } from '../persistence';
import { Ingredient, IngredientGroupMeta } from '../../../shared/types';
import { GroupedIngredients } from '../../types';
import { normalizeIngredient } from '../../../shared/normalization';

function _displaySort(i: Ingredient) {
  return i.display.toLowerCase();
}

function _computeIngredientsByTag(ingredients: Ingredient[], intangibleIngredients: Ingredient[]) {
  const ingredientsByTag = ingredients
    .filter(i => i.tag != null)
    .reduce((obj, i) =>{
      obj[i.tag!] = i;
      return obj;
    }, {} as { [tag: string]: Ingredient });

  // What is going on here?? Is `ingredients` not all possible ingredients?
  intangibleIngredients.forEach(i => {
    ingredientsByTag[i.tag] = i;
    ingredients.push(i);
  });

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

function _computeGroupedIngredients(ingredients: Ingredient[], groups: IngredientGroupMeta[]) {
  return sortBy(
    map(
      groupBy(
        sortBy(
          ingredients.filter(i => i.tangible),
          _displaySort
        ),
        i => i.group
      ),
      (ingredients, groupTag) => ({
        name: groups[findIndex(groups, g => g.type === groupTag)].display,
        ingredients
      })
    ),
    ({ name }) => findIndex(groups, g => g.display === name)
  );
}

export interface IngredientsState {
  groupedIngredients: GroupedIngredients[];
  ingredientsByTag: { [tag: string]: Ingredient };
}

export const reducer = makeReducer<IngredientsState>(assign({
  groupedIngredients: [],
  ingredientsByTag: {}
}, load().ingredients), {
  'set-ingredients': (_state, { ingredients, groups }: { ingredients: Ingredient[], groups: IngredientGroupMeta[] }) => {
    // We don't use state, this is a set-once kind of deal.
    return {
      ingredientsByTag: _computeIngredientsByTag(ingredients, ingredients.filter(i => !i.tangible)),
      groupedIngredients: _computeGroupedIngredients(ingredients, groups)
    };
  }
});

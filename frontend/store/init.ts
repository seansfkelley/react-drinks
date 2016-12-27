import { assign, once, mapValues } from 'lodash';
import * as Promise from 'bluebird';
import * as reqwest from 'reqwest';
import * as log from 'loglevel';

import { store } from '.';
import recipeLoader from './recipeLoader';
import { setIngredients, setRecipesById } from './atomicActions';

export default once(() => {
  const { customRecipeIds } = store.getState().recipes;
  const { defaultRecipeIds } = window as any;

  log.info(`loading ${defaultRecipeIds.length} default recipe(s) and ${customRecipeIds.length} custom recipe(s)`);

  return Promise.all([
    Promise.resolve(reqwest({
      url: '/ingredients',
      method: 'get',
      type: 'json',
      contentType: 'application/json'
    }))
      .then(ingredients => {
        store.dispatch(setIngredients(ingredients));
      })
  ,
    recipeLoader([].concat(customRecipeIds).concat(defaultRecipeIds))
      .then(recipesById => {
        store.dispatch(setRecipesById(mapValues(recipesById, (recipe, recipeId) => assign({ recipeId }, recipe))));
      })
  ]);
});

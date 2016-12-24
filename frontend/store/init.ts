import { assign, once, mapValues } from 'lodash';
import * as Promise from 'bluebird';
import * as reqwest from 'reqwest';
import * as log from 'loglevel';

import { store } from '.';
import recipeLoader from './recipeLoader';

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
        store.dispatch(assign({
          type: 'set-ingredients'
        }, ingredients));
      })
  ,
    recipeLoader([].concat(customRecipeIds).concat(defaultRecipeIds))
      .then(recipesById => {
        store.dispatch({
          type: 'recipes-loaded',
          recipesById: mapValues(recipesById, (recipe, recipeId) => assign({ recipeId }, recipe))
        });
      })
  ]);
});

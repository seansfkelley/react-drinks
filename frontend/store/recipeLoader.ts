import { assign, uniq, pick, size, difference } from 'lodash';
import * as log from 'loglevel';
import * as Promise from 'bluebird';
import * as reqwest from 'reqwest';

import { Recipe } from '../../shared/types';

const LOCALSTORAGE_KEY = 'drinks-app-recipe-cache';
const CACHE: { [recipeId: string]: Recipe } = JSON.parse(localStorage[LOCALSTORAGE_KEY] != null ? localStorage[LOCALSTORAGE_KEY] : '{}');

export default function load(recipeIds: string[]): Promise<{ [recipeId: string]: Recipe }> {
  // These can be non-unique if someone adds a recipe they already have with the new
  // add-recipe-by-code mechanism; eventually we will be able to catch that bug there.
  const uniqueRecipeIds = uniq(recipeIds);
  log.debug(`loading ${recipeIds.length} recipes (${uniqueRecipeIds.length} unique)`);

  const cachedRecipes = pick(CACHE, uniqueRecipeIds) as { [recipeId: string]: Recipe };
  log.debug(`recipe loading hit cache for ${size(cachedRecipes)}/${uniqueRecipeIds.length} recipes`);

  if (size(cachedRecipes) === uniqueRecipeIds.length) {
    return Promise.resolve(cachedRecipes);
  } else {
    const uncachedRecipeIds = difference(uniqueRecipeIds, Object.keys(cachedRecipes));
    log.debug(`requesting ${uncachedRecipeIds.length} uncached recipes`);

    return Promise.resolve(reqwest({
      url: '/recipes/bulk',
      method: 'post',
      type: 'json',
      data: { recipeIds: uncachedRecipeIds }
    }))
      .tap((recipesById: { [recipeId: string]: Recipe }) => {
        log.debug(`got ${size(recipesById)} recipes; caching`);
        assign(CACHE, recipesById);
        localStorage[LOCALSTORAGE_KEY] = JSON.stringify(CACHE);
      })
      .then(recipesById => assign({}, recipesById, cachedRecipes));
  }
};

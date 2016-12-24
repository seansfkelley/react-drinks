const _       = require('lodash');
const log     = require('loglevel');
const Promise = require('bluebird');
const reqwest = require('reqwest');

const LOCALSTORAGE_KEY = 'drinks-app-recipe-cache';
const CACHE            = JSON.parse(localStorage[LOCALSTORAGE_KEY] != null ? localStorage[LOCALSTORAGE_KEY] : '{}');

const load = function(recipeIds) {
  // These can be non-unique if someone adds a recipe they already have with the new
  // add-recipe-by-code mechanism; eventually we will be able to catch that bug there.
  const uniqueRecipeIds = _.uniq(recipeIds);
  log.debug(`loading ${recipeIds.length} recipes (${uniqueRecipeIds.length} unique)`);
  const cachedRecipes = _.pick(CACHE, uniqueRecipeIds);
  log.debug(`recipe loading hit cache for ${_.size(cachedRecipes)}/${uniqueRecipeIds.length} recipes`);
  if (_.size(cachedRecipes) === uniqueRecipeIds.length) {
    return Promise.resolve(cachedRecipes);
  } else {
    const uncachedRecipeIds = _.difference(uniqueRecipeIds, _.keys(cachedRecipes));
    log.debug(`requesting ${uncachedRecipeIds.length} uncached recipes`);
    return Promise.resolve(reqwest({
      url         : '/recipes/bulk',
      method      : 'post',
      type        : 'json',
      data        : { recipeIds : uncachedRecipeIds }
    })
    )
    .tap(function(recipesById) {
      log.debug(`got ${_.size(recipesById)} recipes; caching`);
      _.extend(CACHE, recipesById);
      window.response = recipesById;
      return localStorage[LOCALSTORAGE_KEY] = JSON.stringify(CACHE);
    })
    .then(recipesById => _.extend({}, recipesById, cachedRecipes));
  }
};

module.exports = load;

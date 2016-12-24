#!/usr/bin/env node

const log = require('loglevel');
log.setLevel('info');

if (!process.argv.includes('--force')) {
  log.info('ERROR: will not reseed database unless --force is applied');
  process.exit(1);
}

const startTime = Date.now();

const _       = require('lodash');
const Promise = require('bluebird');
const md5     = require('MD5');

const config = require('../backend/config');
const { recipeDb, ingredientDb, configDb } = require('../backend/database').get();

const defaultDataLoaders = require('../default-data/loaders');

const DEFAULT_RECIPE_LIST_DOC_ID = 'default-recipe-list';
const INGREDIENT_GROUP_DOC_ID    = 'ingredient-groups';

const logAttemptedOverwriteResult = function(result, docType = 'entries') {
  const failures = _.chain(result)
    .filter('error')
    .groupBy('name')
    .value();

  log.info(`${_.reject(result, 'error').length} ${docType} newly inserted`);
  if (_.size(failures)) {
    log.warn(`${__guard__(failures.conflict, x => x.length) != null ? __guard__(failures.conflict, x => x.length) : 0} ${docType} already existed`);
    const nonConflictFailures = _.chain(failures)
      .omit('conflict')
      .values()
      .flatten()
      .value();
    if (nonConflictFailures.length) {
      return log.error(`${nonConflictFailures.length} ${docType} failed for other reasons:\n${nonConflictFailures}`);
    }
  }
};

Promise.resolve()
.then(function() {
  log.info(`seeding database at ${config.couchDb.url}`);

  const recipeFilesToLoad = [
    'iba-recipes',
    'recipes'
  ];

  if (process.argv.includes('--include-custom-recipes')) {
    recipeFilesToLoad.push('custom-recipes');
    recipeFilesToLoad.push('michael-cecconi');
  }

  log.debug(`will load recipes from files: ${recipeFilesToLoad.join(', ')}`);

  const recipesWithId = _.chain(recipeFilesToLoad)
    .map(defaultDataLoaders.loadRecipeFile)
    .flatten()
    // So, we don't really care if this is a hash or not. It just needs to be sufficiently unique.
    // The reason it does this is because it avoids accidentally assigning the same ID to a default
    // recipe (which don't come with any) and a custom recipe (which should retain theirs forever).
    .map(r => _.extend({ _id : md5(JSON.stringify(r)) }, r))
    .value();

  log.info(`${recipesWithId.length} recipes to be inserted`);

  return recipeDb.bulkDocs(recipesWithId)
  .then(result => logAttemptedOverwriteResult(result, 'recipes'))

  .then(() =>
    configDb.get(DEFAULT_RECIPE_LIST_DOC_ID)
    .catch(function(err) {
      if (__guard__(err, x => x.name) === 'not_found') {
        return undefined;
      } else {
        throw err;
      }
    })

    .then(function(result) {
      if (result) {
        return result._rev;
      } else {
        return undefined;
      }
    })
  )

  .then(_rev =>
    configDb.put({
      _id        : DEFAULT_RECIPE_LIST_DOC_ID,
      _rev,
      defaultIds : _.pluck(recipesWithId, '_id')
    }))

  .then(() => log.info(`successfully updated list of default recipe IDs (new count: ${recipesWithId.length})`));
})

.then(function() {
  const ingredients = defaultDataLoaders.loadIngredients();
  log.info(`${ingredients.length} ingredients to be inserted`);

  const ingredientsWithId = _.map(ingredients, i => _.extend({ _id : i.tag }, i));

  return ingredientDb.bulkDocs(ingredientsWithId);
})

.then(result => logAttemptedOverwriteResult(result, 'ingredients'))

.then(() =>
  configDb.get(INGREDIENT_GROUP_DOC_ID)
  .catch(function(err) {
    if (__guard__(err, x => x.name) === 'not_found') {
      return undefined;
    } else {
      throw err;
    }
  })

  .then(function(result) {
    if (result) {
      return result._rev;
    } else {
      return undefined;
    }
  })
)

.then(function(_rev) {
  const orderedGroups = defaultDataLoaders.loadIngredientGroups();

  return configDb.put({
    _id           : INGREDIENT_GROUP_DOC_ID,
    _rev,
    orderedGroups
  })
  .then(() => log.info(`successfully updated list of ordered groups (new count: ${orderedGroups.length})`));
})

.catch(function(err) {
  let left;
  return log.error((left = __guard__(err, x => x.stack) != null ? __guard__(err, x => x.stack) : err) != null ? left : 'unknown error');
})

.finally(() => log.info(`seeding database finished in ${((Date.now() - startTime) / 1000).toFixed(2)}s`));

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
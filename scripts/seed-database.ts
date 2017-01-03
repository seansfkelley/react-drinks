#!/usr/bin/env node

import * as log from 'loglevel';
log.setLevel('info');

if (process.argv.indexOf('--force') !== -1) {
  log.info('ERROR: will not reseed database unless --force is applied');
  process.exit(1);
}

const startTime = Date.now();

import { groupBy, size, omit, values, flatten, extend } from 'lodash';
import * as Promise from 'bluebird';
import * as md5 from 'MD5';

import config from '../backend/config';
import { loadRecipeFile, loadIngredients } from '../default-data/loaders';
import { get as getDatabase } from '../backend/database';

const { recipeDb, ingredientDb, configDb } = getDatabase();

const DEFAULT_RECIPE_LIST_DOC_ID = 'default-recipe-list';

interface ErrorResponse extends PouchDB.Core.Response {
  name?: string;
  error?: string;
}

const logAttemptedOverwriteResult = (result: ErrorResponse[], docType: string = 'entries') => {
  const failures = groupBy(result.filter(r => !!r.error), 'name');

  log.info(`${result.filter(r => !r.error).length} ${docType} newly inserted`);
  if (size(failures)) {
    if (failures['conflict'] && failures['conflict'].length > 0) {
      log.warn(`${failures['conflict'].length} ${docType} already existed`);
    }

    const nonConflictFailures = flatten(values(omit(failures, 'conflict')));
    if (nonConflictFailures.length) {
      return log.error(`${nonConflictFailures.length} ${docType} failed for other reasons:\n${nonConflictFailures}`);
    }
  }
};

function ignoreNotFoundError(error: any) {
  if (!error || error.name !== 'not_found') {
    throw error;
  }
}

function getRevision(result?: { _rev: any }) {
  if (result && result._rev != null) {
    return result._rev;
  } else {
    return undefined;
  }
}

function bestEffortLogError(error: any) {
  let logline;
  if (error) {
    logline = error.stack ? error.stack : error.toString();
  } else {
    logline = 'an unknown error occured!'
  }
  log.error(logline);
}

Promise.resolve()
  .then(() => {
    log.info(`seeding database at ${config.couchDb.url}`);

    const recipeFilesToLoad = ['iba-recipes', 'recipes'];

    if (process.argv.indexOf('--include-custom-recipes') !== -1) {
      recipeFilesToLoad.push('custom-recipes');
      recipeFilesToLoad.push('michael-cecconi');
    }

    log.debug(`will load recipes from files: ${recipeFilesToLoad.join(', ')}`);

    const recipesWithId = flatten(recipeFilesToLoad.map(loadRecipeFile))
      // So, we don't really care if this is a hash or not. It just needs to be sufficiently unique.
      // The reason it does this is because it avoids accidentally assigning the same ID to a default
      // recipe (which don't come with any) and a custom recipe (which should retain theirs forever).
      .map(r => extend({
        _id: md5(JSON.stringify(r))
      }, r));

    log.info(`${recipesWithId.length} recipes to be inserted`);

    return recipeDb
      .bulkDocs(recipesWithId)
      .then(result => logAttemptedOverwriteResult(result, 'recipes'))
      .then(() =>
        configDb.get(DEFAULT_RECIPE_LIST_DOC_ID)
          .then(
            getRevision,
            ignoreNotFoundError
          )
      )
      .then(_rev =>
        configDb.put({
          _id: DEFAULT_RECIPE_LIST_DOC_ID,
          _rev,
          defaultIds: recipesWithId.map(r => r._id)
      }))
      .then(() => log.info(`successfully updated list of default recipe IDs (new count: ${recipesWithId.length})`));
  })
  .then(() => {
    const ingredients = loadIngredients();
    log.info(`${ingredients.length} ingredients to be inserted`);

    const ingredientsWithId = ingredients.map(i => extend({ _id: i.tag }, i));

    return ingredientDb.bulkDocs(ingredientsWithId);
  })
  .then(result => logAttemptedOverwriteResult(result, 'ingredients'))
  .catch(bestEffortLogError)
  .finally(() => log.info(`seeding database finished in ${((Date.now() - startTime) / 1000).toFixed(2)}s`));


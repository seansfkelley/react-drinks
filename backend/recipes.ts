import {} from 'lodash';
import * as log from 'loglevel';
import * as Promise from 'bluebird';

const { recipeDb, configDb } = require('./database').get();

const getDefaultRecipeIds = () => configDb.get('default-recipe-list').then(({ defaultIds }) => defaultIds);

const save = recipe => recipeDb.post(recipe).then(function ({ ok, id, rev }) {
  log.info(`saved new recipe with ID ${ id }`);
  return id;
});

const load = recipeId => recipeDb.get(recipeId).then(function (recipe) {
  if (recipe) {
    return _.extend({ recipeId }, _.omit(recipe, '_id'));
  } else {
    return log.info(`failed to find recipe with ID '${ recipeId }'`);
  }
});

const bulkLoad = function (recipeIds) {
  if (!__guard__(recipeIds, x => x.length)) {
    return Promise.resolve({});
  } else {
    return recipeDb.allDocs({
      keys: recipeIds,
      include_docs: true
    }).then(function ({ total_rows, offset, rows }) {
      // rows -> { id, key, value: { rev }, doc: { ... }}
      const recipes = _.chain(rows).pluck('doc').compact().indexBy('_id').mapValues(r => _.omit(r, '_id', '_rev')).value();

      const loadedIds = _.keys(recipes);
      const missingIds = _.difference(recipeIds, loadedIds);
      if (missingIds.length) {
        log.warn(`failed to bulk-load some recipes: ${ missingIds.join(', ') }`);
      }

      return recipes;
    });
  }
};

module.exports = {
  getDefaultRecipeIds,
  save,
  load,
  bulkLoad
};

function __guard__(value, transform) {
  return typeof value !== 'undefined' && value !== null ? transform(value) : undefined;
}


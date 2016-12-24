import {} from 'lodash';

const { ingredientDb, configDb } = require('./database').get();

const getIngredients = () => ingredientDb.allDocs({
  include_docs: true
}).then(({ total_rows, offset, rows }) =>
// rows -> { id, key, value: { rev }, doc: { ... }}
_.chain(rows).pluck('doc').map(r => _.omit(r, '_id', '_rev')).value());

const getGroups = () => configDb.get('ingredient-groups').then(({ orderedGroups }) => orderedGroups);

module.exports = {
  getIngredients,
  getGroups
};


_       = require 'lodash'
Promise = require 'bluebird'
PouchDB = require 'pouchdb'

config = require('../backend/config').get()

ingredientDb = new PouchDB config.couchDb.url + config.couchDb.ingredientDbName
configDb     = new PouchDB config.couchDb.url + config.couchDb.configDbName

getIngredients = ->
  return Promise.resolve ingredientDb.allDocs({
    include_docs : true
  })
  .then ({ total_rows, offset, rows }) ->
    # rows -> { id, key, value: { rev }, doc: { ... }}
    return _.chain(rows)
      .pluck 'doc'
      .map (r) -> _.omit r, '_id', '_rev'
      .value()

getGroups = ->
  return Promise.resolve configDb.get('ingredient-groups')
  .then ({ orderedGroups }) -> orderedGroups

module.exports = {
  getIngredients
  getGroups
}

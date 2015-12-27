_       = require 'lodash'
Promise = require 'bluebird'
PouchDB = require 'pouchdb'

{ ingredientDb, configDb } = require('./database').get()

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

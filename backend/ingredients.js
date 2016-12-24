_ = require 'lodash'

{ ingredientDb, configDb } = require('./database').get()

getIngredients = ->
  return ingredientDb.allDocs({
    include_docs : true
  })
  .then ({ total_rows, offset, rows }) ->
    # rows -> { id, key, value: { rev }, doc: { ... }}
    return _.chain(rows)
      .pluck 'doc'
      .map (r) -> _.omit r, '_id', '_rev'
      .value()

getGroups = ->
  return configDb.get('ingredient-groups')
  .then ({ orderedGroups }) -> orderedGroups

module.exports = {
  getIngredients
  getGroups
}

_       = require 'lodash'
Promise = require 'bluebird'
PouchDB = require 'pouchdb'

config   = require('../backend/config').get()
recipeDb = new PouchDB config.couchDbUrl + config.recipeDbName
configDb = new PouchDB config.couchDbUrl + config.configDbName

getDefaultRecipeIds = ->
  return Promise.resolve configDb.get('default-recipe-list')
  .then ({ defaultIds }) -> defaultIds

save = (recipe) ->
  recipe = _.omit recipe, 'recipeId'

  return Promise.resolve recipeDb.post(recipe)
  .then ({ ok, id, rev }) ->
    log.info "saved new recipe with ID #{id}"
    return id

load = (recipeId) ->
  return Promise.resolve recipeDb.get(recipeId)
  .then (recipe) ->
    if recipe
      return _.extend { recipeId }, _.omit(recipe, '_id')
    else
      log.info "failed to find recipe with ID '#{recipeId}'"

bulkLoad = (recipeIds) ->
  return Promise.resolve recipeDb.allDocs({
    keys         : recipeIds
    include_docs : true
  })
  .then ({ total_rows, offset, rows }) ->
    # rows -> { id, key, value: { rev }, doc: { ... }}
    recipes = _.chain(rows)
      .pluck 'doc'
      .indexBy '_id'
      .map (r) -> _.extend { recipeId : r._id }, _.omit(r, '_id', '_rev')
      .indexBy 'recipeId'
      .value()

    loadedIds = _.keys recipes
    missingIds = _.difference recipeIds, loadedIds
    if missingIds.length
      log.warn "failed to bulk-load some recipes: #{missingIds.join ', '}"

    return recipes

module.exports = {
  getDefaultRecipeIds
  save
  load
  bulkLoad
}

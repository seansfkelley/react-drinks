_       = require 'lodash'
log     = require 'loglevel'
Promise = require 'bluebird'

{ recipeDb, configDb } = require('./database').get()

getDefaultRecipeIds = ->
  return configDb.get('default-recipe-list')
  .then ({ defaultIds }) -> defaultIds

save = (recipe) ->
  return recipeDb.post(recipe)
  .then ({ ok, id, rev }) ->
    log.info "saved new recipe with ID #{id}"
    return id

load = (recipeId) ->
  return recipeDb.get(recipeId)
  .then (recipe) ->
    if recipe
      return _.extend { recipeId }, _.omit(recipe, '_id')
    else
      log.info "failed to find recipe with ID '#{recipeId}'"

bulkLoad = (recipeIds) ->
  if not recipeIds?.length
    log.debug "bulk-load requested to load nothing; parameter was #{JSON.stringify recipeIds}"
    return Promise.resolve {}
  else
    log.debug "bulk-loading #{recipeIds.length} recipes"
    return recipeDb.allDocs({
      keys         : recipeIds
      include_docs : true
    })
    .then ({ total_rows, offset, rows }) ->
      # rows -> { id, key, value: { rev }, doc: { ... }}
      recipes = _.chain(rows)
        .pluck 'doc'
        .compact()
        .indexBy '_id'
        .mapValues (r) -> _.omit r, '_id', '_rev'
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

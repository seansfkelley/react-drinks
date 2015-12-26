#!/usr/bin/env coffee

log = require 'loglevel'
log.setLevel 'info'

startTime = Date.now()

_       = require 'lodash'
Promise = require 'bluebird'
PouchDB = require 'pouchdb'

config   = require('../backend/config').get()
recipeDb = new PouchDB config.couchDbUrl + config.recipeDbName
configDb = new PouchDB config.couchDbUrl + config.configDbName

{ loadRecipeFile } = require '../backend/defaultDataLoaders'

DEFAULT_RECIPE_LIST_DOC_ID = 'default-recipe-list'

recipeFilesToLoad = [
  'iba-recipes'
  'recipes'
]

if '--include-custom-recipes' in process.argv
  recipeFilesToLoad.push 'custom-recipes'
  recipeFilesToLoad.push 'michael-cecconi'

log.debug "will load recipes from files: #{recipeFilesToLoad.join ', '}"

recipesWithId = _.chain(recipeFilesToLoad)
  .map loadRecipeFile
  .flatten()
  .map (r) -> _.extend { _id : r.recipeId }, _.omit(r, 'recipeId')
  .value()

log.info "#{recipesWithId.length} recipes to be inserted"

Promise.resolve()
.then ->
  return recipeDb.bulkDocs recipesWithId

.then (result) ->
  failures = _.chain(result)
    .filter 'error'
    .groupBy 'name'
    .value()

  log.info "#{_.reject(result, 'error').length} recipes newly inserted"
  if _.size(failures)
    log.warn "#{failures.conflict?.length ? 0} recipes already existed"
    nonConflictFailures = _.chain(failures)
      .omit 'conflict'
      .values()
      .flatten()
      .value()
    if nonConflictFailures.length
      log.error "#{nonConflictFailures.length} recipes failed for other reasons:\n#{nonConflictFailures}"

.then ->
  return configDb.get DEFAULT_RECIPE_LIST_DOC_ID

.then (result) ->
  if result
    return result._rev
  else
    return undefined

.then (_rev) ->
  return configDb.put {
    _id        : 'default-recipe-list'
    _rev
    defaultIds : _.pluck(recipesWithId, '_id')
  }

.then ->
  log.info 'successfully updated list of default recipe IDs'

.catch (err) ->
  log.error err

.finally ->
  log.info "seeding database finished in #{((Date.now() - startTime) / 1000).toFixed(2)}s"

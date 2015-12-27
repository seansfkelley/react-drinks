#!/usr/bin/env coffee

log = require 'loglevel'
log.setLevel 'info'

startTime = Date.now()

_       = require 'lodash'
Promise = require 'bluebird'
PouchDB = require 'pouchdb'

config = require('../backend/config').get()

recipeDb     = new PouchDB config.couchDb.url + config.couchDb.recipeDbName
configDb     = new PouchDB config.couchDb.url + config.couchDb.configDbName
ingredientDb = new PouchDB config.couchDb.url + config.couchDb.ingredientDbName

defaultDataLoaders = require '../default-data/loaders'

DEFAULT_RECIPE_LIST_DOC_ID = 'default-recipe-list'
INGREDIENT_GROUP_DOC_ID    = 'ingredient-groups'

logAttemptedOverwriteResult = (result, docType = 'entries') ->
  failures = _.chain(result)
    .filter 'error'
    .groupBy 'name'
    .value()

  log.info "#{_.reject(result, 'error').length} #{docType} newly inserted"
  if _.size(failures)
    log.warn "#{failures.conflict?.length ? 0} #{docType} already existed"
    nonConflictFailures = _.chain(failures)
      .omit 'conflict'
      .values()
      .flatten()
      .value()
    if nonConflictFailures.length
      log.error "#{nonConflictFailures.length} #{docType} failed for other reasons:\n#{nonConflictFailures}"

Promise.resolve()
.then ->
  recipeFilesToLoad = [
    'iba-recipes'
    'recipes'
  ]

  if '--include-custom-recipes' in process.argv
    recipeFilesToLoad.push 'custom-recipes'
    recipeFilesToLoad.push 'michael-cecconi'

  log.debug "will load recipes from files: #{recipeFilesToLoad.join ', '}"

  recipesWithId = _.chain(recipeFilesToLoad)
    .map defaultDataLoaders.loadRecipeFile
    .flatten()
    .map (r) -> _.extend { _id : r.recipeId }, _.omit(r, 'recipeId')
    .value()

  log.info "#{recipesWithId.length} recipes to be inserted"

  return Promise.resolve recipeDb.bulkDocs(recipesWithId)
  .then (result) ->
    logAttemptedOverwriteResult result, 'recipes'

  .then ->
    return Promise.resolve configDb.get(DEFAULT_RECIPE_LIST_DOC_ID)
    .catch (err) ->
      if err?.name == 'not_found'
        return undefined
      else
        throw err

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

.then ->
  ingredients = defaultDataLoaders.loadIngredients()
  log.info "#{ingredients.length} ingredients to be inserted"

  ingredientsWithId = _.map ingredients, (i) -> _.extend { _id : i.tag }, i

  return ingredientDb.bulkDocs ingredientsWithId

.then (result) ->
  logAttemptedOverwriteResult result, 'ingredients'

.then ->
  return Promise.resolve configDb.get(INGREDIENT_GROUP_DOC_ID)
  .catch (err) ->
    if err?.name == 'not_found'
      return undefined
    else
      throw err

  .then (result) ->
    if result
      return result._rev
    else
      return undefined

.then (_rev) ->
  return configDb.put {
    _id           : INGREDIENT_GROUP_DOC_ID
    _rev
    orderedGroups : defaultDataLoaders.loadIngredientGroups()
  }

.then ->
  log.info 'successfully updated list of ordered groups'

.catch (err) ->
  log.error err?.stack ? err ? 'unknown error'

.finally ->
  log.info "seeding database finished in #{((Date.now() - startTime) / 1000).toFixed(2)}s"

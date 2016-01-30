_       = require 'lodash'
log     = require 'loglevel'
Promise = require 'bluebird'
reqwest = require 'reqwest'

LOCALSTORAGE_KEY = 'drinks-app-recipe-cache'
CACHE            = JSON.parse(localStorage[LOCALSTORAGE_KEY] ? '{}')

load = (recipeIds) ->
  # These can be non-unique if someone adds a recipe they already have with the new
  # add-recipe-by-code mechanism; eventually we will be able to catch that bug there.
  uniqueRecipeIds = _.uniq recipeIds
  log.debug "loading #{recipeIds.length} recipes (#{uniqueRecipeIds.length} unique)"
  cachedRecipes = _.pick CACHE, uniqueRecipeIds
  log.debug "recipe loading hit cache for #{_.size(cachedRecipes)}/#{uniqueRecipeIds.length} recipes"
  if _.size(cachedRecipes) == uniqueRecipeIds.length
    return Promise.resolve cachedRecipes
  else
    uncachedRecipeIds = _.difference uniqueRecipeIds, _.keys(cachedRecipes)
    log.debug "requesting #{uncachedRecipeIds.length} uncached recipes"
    return Promise.resolve reqwest({
      url         : '/recipes/bulk'
      method      : 'post'
      type        : 'json'
      data        : { recipeIds : uncachedRecipeIds }
    })
    .tap (recipesById) ->
      log.debug "got #{_.size(recipesById)} recipes; caching"
      _.extend CACHE, recipesById
      localStorage[LOCALSTORAGE_KEY] = JSON.stringify(CACHE)
    .then (recipesById) ->
      return _.extend {}, recipesById, cachedRecipes

module.exports = load

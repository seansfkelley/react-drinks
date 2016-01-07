_       = require 'lodash'
log     = require 'loglevel'
Promise = require 'bluebird'
reqwest = require 'reqwest'

LOCALSTORAGE_KEY = 'drinks-app-recipe-cache'
CACHE            = JSON.parse(localStorage[LOCALSTORAGE_KEY] ? '{}')

load = (recipeIds) ->
  cachedRecipes = _.pick CACHE, recipeIds
  log.debug "recipe loading hit cache for #{_.size(cachedRecipes)}/#{recipeIds.length} recipes"
  if _.size(cachedRecipes) == recipeIds.length
    return Promise.resolve cachedRecipes
  else
    uncachedRecipeIds = _.difference recipeIds, _.keys(cachedRecipes)
    return Promise.resolve reqwest({
      url         : '/recipes/bulk'
      method      : 'post'
      type        : 'json'
      data        : { recipeIds : uncachedRecipeIds }
    })
    .tap (recipesById) ->
      log.debug "caching #{_.size(recipesById)} recipes"
      _.extend CACHE, recipesById
      window.response = recipesById
      localStorage[LOCALSTORAGE_KEY] = JSON.stringify(CACHE)
    .then (recipesById) ->
      return _.extend {}, recipesById, cachedRecipes

module.exports = load

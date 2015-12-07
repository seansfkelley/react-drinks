Promise = require 'bluebird'
reqwest = require 'reqwest'

LOCALSTORAGE_KEY = 'drinks-app-recipe-cache'
CACHE            = JSON.parse(localStorage[LOCALSTORAGE_KEY] ? '{}')

load = (recipeIds) ->
  return Promise.resolve reqwest({
    url    : '/recipes'
    method : 'post'
    type   : 'json'
    data   : { recipeIds }
  })
  .tap (recipes) ->
    _.extend CACHE, _.indexBy(recipes, 'recipeId')

module.exports = load

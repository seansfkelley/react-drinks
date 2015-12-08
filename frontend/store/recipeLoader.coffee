Promise = require 'bluebird'
reqwest = require 'reqwest'

LOCALSTORAGE_KEY = 'drinks-app-recipe-cache'
CACHE            = JSON.parse(localStorage[LOCALSTORAGE_KEY] ? '{}')

load = (recipeIds) ->
  return Promise.resolve reqwest({
    url    : '/recipes/bulk'
    method : 'post'
    type   : 'json'
    data   : { recipeIds }
  })
  .tap (recipesById) ->
    _.extend CACHE, recipesById

module.exports = load

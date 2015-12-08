Promise = require 'bluebird'
reqwest = require 'reqwest'

store = require '.'

recipeLoader = require './recipeLoader'

module.exports = _.once ->
  idsToLoad = []
    .concat store.getState().recipes.customRecipeIds
    .concat window.defaultRecipeIds

  return Promise.all [
    Promise.resolve reqwest({
      url    : '/ingredients'
      method : 'get'
      type   : 'json'
    })
    .then (ingredients) ->
      store.dispatch _.extend {
        type : 'set-ingredients'
      }, ingredients
  ,
    recipeLoader(idsToLoad)
    .then (recipesById) ->
      store.dispatch {
        type : 'recipes-loaded'
        recipesById
      }
  ]

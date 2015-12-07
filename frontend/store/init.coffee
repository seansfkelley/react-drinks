Promise = require 'bluebird'
reqwest = require 'reqwest'

store = require '.'

recipeLoader = require './recipeLoader'

module.exports = _.once ->
  return Promise.all [
    Promise.resolve reqwest({
      url    : '/ingredients'
      method : 'get'
      type   : 'json'
    })
    .then (ingredients) =>
      store.dispatch _.extend {
        type : 'set-ingredients'
      }, ingredients
  ,
    recipeLoader(window.defaultRecipeIds)
    # Promise.resolve reqwest({
    #   url    : '/recipes'
    #   method : 'get'
    #   type   : 'json'
    # })
    # .then (recipes) =>
    #   store.dispatch {
    #     type : 'set-default-recipes'
    #     recipes
    #   }
  ]

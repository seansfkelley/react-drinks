Promise = require 'bluebird'
reqwest = require 'reqwest'
log     = require 'loglevel'

store = require '.'

recipeLoader = require './recipeLoader'

module.exports = _.once ->
  customRecipeIds  = store.getState().recipes.customRecipeIds
  defaultRecipeIds = window.defaultRecipeIds

  log.info "loading #{defaultRecipeIds.length} default recipe(s) and #{customRecipeIds.length} custom recipe(s)"

  return Promise.all [
    Promise.resolve reqwest({
      url         : '/ingredients'
      method      : 'get'
      type        : 'json'
      contentType : 'application/json'
    })
    .then (ingredients) ->
      store.dispatch _.extend {
        type : 'set-ingredients'
      }, ingredients
  ,
    recipeLoader([].concat(customRecipeIds).concat(defaultRecipeIds))
    .then (recipesById) ->
      store.dispatch {
        type        : 'recipes-loaded'
        recipesById : _.mapValues recipesById, (recipe, recipeId) -> _.extend { recipeId }, recipe
      }
  ]

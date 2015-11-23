_ = require 'lodash'

module.exports = require('./makeReducer') _.extend({
  recipeViewingIndex : null
  favoritedRecipeIds : []
}, require('../persistence').load().ui), {
  'set-recipe-viewing-index' : (state, { index }) ->
    return _.defaults { recipeViewingIndex : index }, state

  'favorite-recipe' : (state, { recipeId }) ->
    return _.defaults { favoritedRecipeIds : _.union state.favoritedRecipeIds, [ recipeId ] }, state

  'unfavorite-recipe' : (state, { recipeId }) ->
    return _.defaults { favoritedRecipeIds : _.without state.favoritedRecipeIds, recipeId }, state
}

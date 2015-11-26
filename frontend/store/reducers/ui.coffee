_ = require 'lodash'

module.exports = require('./makeReducer') _.extend({
  recipeViewingIndex       : null
  currentlyViewedRecipeIds : null
  favoritedRecipeIds       : []
}, require('../persistence').load().ui), {
  'set-recipe-viewing-index' : (state, { index }) ->
    return _.defaults { recipeViewingIndex : index }, state

  'set-recipe-viewing-ids' : (state, { recipeIds }) ->
    return _.defaults { currentlyViewedRecipeIds : recipeIds }, state

  'favorite-recipe' : (state, { recipeId }) ->
    return _.defaults { favoritedRecipeIds : _.union state.favoritedRecipeIds, [ recipeId ] }, state

  'unfavorite-recipe' : (state, { recipeId }) ->
    return _.defaults { favoritedRecipeIds : _.without state.favoritedRecipeIds, recipeId }, state
}

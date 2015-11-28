_ = require 'lodash'

module.exports = require('./makeReducer') _.extend({
  recipeViewingIndex       : 0
  currentlyViewedRecipeIds : []
  favoritedRecipeIds       : []

  showingRecipeViewer      : false
  showingRecipeEditor      : false
  showingSidebar           : false
}, require('../persistence').load().ui), {
  'set-recipe-viewing-index' : (state, { index }) ->
    return _.defaults { recipeViewingIndex : index }, state

  'set-recipe-viewing-ids' : (state, { recipeIds }) ->
    throw new Error

  'favorite-recipe' : (state, { recipeId }) ->
    return _.defaults { favoritedRecipeIds : _.union state.favoritedRecipeIds, [ recipeId ] }, state

  'unfavorite-recipe' : (state, { recipeId }) ->
    return _.defaults { favoritedRecipeIds : _.without state.favoritedRecipeIds, recipeId }, state

  'show-recipe-viewer' : (state, { index, recipeIds }) ->
    return _.defaults {
      showingRecipeViewer      : true
      recipeViewingIndex       : index
      currentlyViewedRecipeIds : recipeIds
     }, state

  'hide-recipe-viewer' : (state) ->
    return _.defaults {
      showingRecipeViewer      : false
      recipeViewingIndex       : 0
      currentlyViewedRecipeIds : []
     }, state

  'show-recipe-editor' : (state) ->
    return _.defaults { showingRecipeEditor : true }, state

  'hide-recipe-editor' : (state) ->
    return _.defaults { showingRecipeEditor : false }, state

  'show-sidebar' : (state) ->
    return _.defaults { showingSidebar : true }, state

  'hide-sidebar' : (state) ->
    return _.defaults { showingSidebar : false }, state

}

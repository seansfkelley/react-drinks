_ = require 'lodash'

module.exports = require('./makeReducer') _.extend({
  errorMessage             : null
  recipeViewingIndex       : 0
  currentlyViewedRecipeIds : []
  favoritedRecipeIds       : []

  showingRecipeViewer      : false
  showingRecipeEditor      : false
  showingSidebar           : false
  showingListSelector      : false
}, require('../persistence').load().ui), {
  'rewrite-recipe-id' : (state, { from, to }) ->
    { currentlyViewedRecipeIds, favoritedRecipeIds } = state

    i = _.indexOf currentlyViewedRecipeIds, from
    if i != -1
      currentlyViewedRecipeIds = _.clone currentlyViewedRecipeIds
      currentlyViewedRecipeIds[i] = to

    i = _.indexOf favoritedRecipeIds, from
    if i != -1
      favoritedRecipeIds = _.clone favoritedRecipeIds
      favoritedRecipeIds[i] = to

    return _.defaults { currentlyViewedRecipeIds, favoritedRecipeIds }, state

  'set-recipe-viewing-index' : (state, { index }) ->
    return _.defaults { recipeViewingIndex : index }, state

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

  'show-list-selector' : (state) ->
    return _.defaults { showingListSelector : true }, state

  'hide-list-selector' : (state) ->
    return _.defaults { showingListSelector : false }, state

  'error-message' : (state, { message }) ->
    return _.defaults { errorMessage : message }, state
}

_           = require 'lodash'
definitions = require '../../../shared/definitions'

module.exports = require('./makeReducer') _.extend({
  recipeViewingIndex : null
  favoritedRecipeIds : []
  selectedRecipeList : definitions.RECIPE_LIST_TYPES[0]
}, require('../persistence').load().ui), {
  'set-recipe-viewing-index' : (state, { index }) ->
    return _.defaults { recipeViewingIndex : index }, state

  'favorite-recipe' : (state, { recipeId }) ->
    return _.defaults { favoritedRecipeIds : _.union state.favoritedRecipeIds, [ recipeId ] }, state

  'unfavorite-recipe' : (state, { recipeId }) ->
    return _.defaults { favoritedRecipeIds : _.without state.favoritedRecipeIds, recipeId }, state

  'set-selected-recipe-list' : (state, { listType }) ->
    return _.defaults { selectedRecipeList : listType }, state
}

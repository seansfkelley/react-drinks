_ = require 'lodash'

normalization = require '../../shared/normalization'

module.exports = (store) ->
  recipeEditorState = store.getState().recipeEditor

  ingredients = _.map recipeEditorState.ingredients, (ingredient) =>
    return _.pick _.extend({ tag : ingredient.tag }, ingredient.display), _.identity

  recipe = _.chain recipeEditorState
    .pick 'name', 'instructions', 'notes', 'base', 'originalRecipeId'
    .extend { ingredients, isCustom : true }
    .pick _.identity
    .value()

  return normalization.normalizeRecipe recipe

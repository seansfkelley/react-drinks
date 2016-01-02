_ = require 'lodash'

normalization = require '../../shared/normalization'

module.exports = (store) ->
  editableRecipeState = store.getState().editableRecipe

  ingredients = _.map editableRecipeState.ingredients, (ingredient) =>
    return _.pick _.extend({ tag : ingredient.tag }, ingredient.display), _.identity

  recipe = _.chain editableRecipeState
    .pick 'name', 'instructions', 'notes', 'base', 'originalRecipeId'
    .extend { ingredients, isCustom : true }
    .pick _.identity
    .value()

  return normalization.normalizeRecipe recipe

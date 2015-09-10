_   = require 'lodash'

computeMixabilityForAll = require './computeMixabilityForAll'

mixabilityByRecipeId = ({
  ingredientsByTag
  alphabeticalRecipes
  selectedIngredientTags
}) ->
  mixableRecipes = computeMixabilityForAll { ingredientsByTag, alphabeticalRecipes, selectedIngredientTags }
  return _.extend {}, _.map(mixableRecipes, (recipes, missing) ->
    missing = +missing
    return _.reduce recipes, ((obj, r) -> obj[r.recipeId] = missing ; return obj), {}
  )...

module.exports = _.extend mixabilityByRecipeId, {
  stateSelector :
    ingredientsByTag       : 'ingredients.ingredientsByTag'
    alphabeticalRecipes    : 'recipes.alphabeticalRecipes'
    selectedIngredientTags : 'filters.selectedIngredientTags'
}

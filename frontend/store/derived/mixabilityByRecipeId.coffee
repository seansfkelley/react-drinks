_   = require 'lodash'

assert = require '../../../shared/tinyassert'

memoize = require './memoize'
computeMixabilityForAll = require('./computeMixabilityForAll').memoized

mixabilityByRecipeId = ({
  ingredientsByTag
  recipes
  ingredientTags
}) ->
  assert ingredientsByTag
  assert recipes
  assert ingredientTags

  mixableRecipes = computeMixabilityForAll { ingredientsByTag, recipes, ingredientTags }
  return _.extend {}, _.map(mixableRecipes, (recipes, missing) ->
    missing = +missing
    return _.reduce recipes, ((obj, r) -> obj[r.recipeId] = missing ; return obj), {}
  )...

module.exports = _.extend mixabilityByRecipeId, {
  memoized      : memoize mixabilityByRecipeId
  stateSelector :
    ingredientsByTag : 'ingredients.ingredientsByTag'
    recipes          : 'recipes.alphabeticalRecipes'
    ingredientTags   : 'filters.selectedIngredientTags'
}

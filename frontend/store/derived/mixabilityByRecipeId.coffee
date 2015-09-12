_   = require 'lodash'

assert = require '../../../shared/tinyassert'

memoize               = require './memoize'
mixabilityByRecipeId2 = require('./mixabilityByRecipeId2').memoized

mixabilityByRecipeId = ({
  ingredientsByTag
  recipes
  ingredientTags
}) ->
  assert ingredientsByTag
  assert recipes
  assert ingredientTags

  mixableRecipes = mixabilityByRecipeId2 { ingredientsByTag, recipes, ingredientTags }
  return _.extend {}, _.map(mixableRecipes, (recipes, missing) ->
    missing = +missing
    return _.reduce recipes, ((obj, r) -> obj[r.recipeId] = missing ; return obj), {}
  )...

module.exports = _.extend mixabilityByRecipeId, {
  memoized : memoize mixabilityByRecipeId
}

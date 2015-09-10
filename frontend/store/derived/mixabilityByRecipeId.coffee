_   = require 'lodash'

assert = require '../../../shared/tinyassert'

memoize          = require './memoize'
mixabilityForAll = require('./mixabilityForAll').memoized

mixabilityByRecipeId = ({
  ingredientsByTag
  recipes
  ingredientTags
}) ->
  assert ingredientsByTag
  assert recipes
  assert ingredientTags

  mixableRecipes = mixabilityForAll { ingredientsByTag, recipes, ingredientTags }
  return _.extend {}, _.map(mixableRecipes, (recipes, missing) ->
    missing = +missing
    return _.reduce recipes, ((obj, r) -> obj[r.recipeId] = missing ; return obj), {}
  )...

module.exports = _.extend mixabilityByRecipeId, {
  memoized : memoize mixabilityByRecipeId
}

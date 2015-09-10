_   = require 'lodash'
log = require 'loglevel'

assert      = require '../../../shared/tinyassert'
definitions = require '../../../shared/definitions'

mixabilityByRecipeId = require './mixabilityByRecipeId'
computeMixabilityForAll = require './computeMixabilityForAll'
recipeMatchesSearchTerm = require './recipeMatchesSearchTerm'

_nestedFilter = (list, filterFn) ->
  filteredList = []
  for { key, recipes } in list
    recipes = _.filter recipes, filterFn
    if recipes.length
      filteredList.push { key, recipes }
  return filteredList

MIXABILITY_FILTER_RANGES = {
  mixable          : [ 0, 0 ]
  nearMixable      : [ 1, 1 ]
  notReallyMixable : [ 2, 100 ]
}

filteredGroupedRecipes = ({
  ingredientsByTag
  groupedRecipes
  baseLiquorFilter
  searchTerm
  mixabilityFilters
  ingredientTags
}) ->
  searchTerm ?= ''

  assert ingredientsByTag
  assert groupedRecipes
  assert baseLiquorFilter
  assert mixabilityFilters
  assert ingredientTags

  mixableRecipes = computeMixabilityForAll { ingredientsByTag, recipes : groupedRecipes, ingredientTags }
  mixabilityById = mixabilityByRecipeId { ingredientsByTag, recipes : groupedRecipes, ingredientTags }

  filteredRecipes = _.chain mixableRecipes
    .values()
    .flatten()
    .sortBy 'sortName'
    # group by should include a clause for numbers
    .groupBy (r) -> r.sortName[0].toLowerCase()
    .map (recipes, key) -> { recipes, key }
    .sortBy 'key'
    .value()

  if baseLiquorFilter and baseLiquorFilter != definitions.ANY_BASE_LIQUOR
    filteredRecipes = _nestedFilter filteredRecipes, (r) ->
      if _.isString r.base
        return r.base == baseLiquorFilter
      else if _.isArray r.base
        return baseLiquorFilter in r.base
      else
        log.warn "recipe '#{r.name}' has a non-string, non-array base: #{r.base}"
        return false

  ranges = _.chain mixabilityFilters
    .pick _.identity
    .map (_, f) -> MIXABILITY_FILTER_RANGES[f]
    .value()

  filteredRecipes = _nestedFilter filteredRecipes, (r) =>
    for [ min, max ] in ranges
      if min <= mixabilityById[r.recipeId] <= max
        return true
    return false

  if searchTerm.trim()
    filteredRecipes = _nestedFilter filteredRecipes, (r) ->
      return recipeMatchesSearchTerm {
        recipe : r
        searchTerm : searchTerm
        ingredientsByTag
      }

  return filteredRecipes

module.exports = _.extend filteredGroupedRecipes, {
  stateSelector :
    ingredientsByTag  : 'ingredients.ingredientsByTag'
    groupedRecipes    : 'recipes.alphabeticalRecipes'
    baseLiquorFilter  : 'filters.baseLiquorFilter'
    searchTerm        : 'filters.recipeSearchTerm'
    mixabilityFilters : 'filters.mixabilityFilters'
    ingredientTags    : 'filters.selectedIngredientTags'
}

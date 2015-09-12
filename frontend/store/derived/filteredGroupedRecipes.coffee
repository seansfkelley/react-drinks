_   = require 'lodash'
log = require 'loglevel'

assert      = require '../../../shared/tinyassert'
definitions = require '../../../shared/definitions'

memoize                 = require './memoize'
mixabilityByRecipeId2   = require('./mixabilityByRecipeId2').memoized
mixabilityByRecipeId    = require('./mixabilityByRecipeId').memoized
recipeMatchesSearchTerm = require('./recipeMatchesSearchTerm').memoized

MIXABILITY_FILTER_RANGES = {
  mixable          : [ 0, 0 ]
  nearMixable      : [ 1, 1 ]
  notReallyMixable : [ 2, 100 ]
}

# hee hee
nofilter = -> true

_baseLiquorFilter = (baseLiquorFilter) ->
  if baseLiquorFilter != definitions.ANY_BASE_LIQUOR
    return (recipe) ->
      if _.isString recipe.base
        return recipe.base == baseLiquorFilter
      else if _.isArray recipe.base
        return baseLiquorFilter in recipe.base
      else
        log.warn "recipe '#{recipe.name}' has a non-string, non-array base: #{recipe.base}"
        return false
  else
    return nofilter

_mixabilityFilter = (mixabilityById, mixabilityFilters) ->
  ranges = _.chain mixabilityFilters
    .pick _.identity
    .map (_, f) -> MIXABILITY_FILTER_RANGES[f]
    .value()

  return (recipe) ->
    for [ min, max ] in ranges
      if min <= mixabilityById[recipe.recipeId] <= max
        return true
    return false

_searchTermFilter = (searchTerm, ingredientsByTag) ->
  searchTerm = searchTerm.trim()
  if searchTerm
    return (recipe) ->
      return recipeMatchesSearchTerm {
        recipe
        searchTerm
        ingredientsByTag
      }
  else
    return nofilter

_sortAndGroupAlphabetical = (recipes) ->
  return _.chain recipes
    .sortBy 'sortName'
    .groupBy (r) ->
      key = r.sortName[0].toLowerCase()
      if /\d/.test key
        return '#'
      else
        return key
    .map (recipes, key) -> { recipes, key }
    .sortBy 'key'
    .value()

filteredGroupedRecipes = ({
  ingredientsByTag
  recipes
  baseLiquorFilter
  searchTerm
  mixabilityFilters
  ingredientTags
}) ->
  searchTerm ?= ''
  baseLiquorFilter ?= definitions.ANY_BASE_LIQUOR

  assert ingredientsByTag
  assert recipes
  assert mixabilityFilters
  assert ingredientTags

  recipesWithMixability = mixabilityByRecipeId2 { ingredientsByTag, recipes, ingredientTags }
  mixabilityById = mixabilityByRecipeId { ingredientsByTag, recipes, ingredientTags }

  filteredRecipes = _.chain recipesWithMixability
    .values()
    .flatten()
    .filter _baseLiquorFilter(baseLiquorFilter)
    .filter _mixabilityFilter(mixabilityById, mixabilityFilters)
    .filter _searchTermFilter(searchTerm, ingredientsByTag)
    .value()

  return _sortAndGroupAlphabetical filteredRecipes

module.exports = _.extend filteredGroupedRecipes, {
  memoized : memoize filteredGroupedRecipes
  __test   : {
    _baseLiquorFilter
    _mixabilityFilter
    _searchTermFilter
    _sortAndGroupAlphabetical
  }
}

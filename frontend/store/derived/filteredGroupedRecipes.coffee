_   = require 'lodash'
log = require 'loglevel'

assert      = require '../../../shared/tinyassert'
definitions = require '../../../shared/definitions'

memoize                    = require './memoize'
ingredientSplitsByRecipeId = require('./ingredientSplitsByRecipeId').memoized
recipeMatchesSearchTerm    = require('./recipeMatchesSearchTerm').memoized

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

_mixabilityFilter = (includeAllDrinks, ingredientSplitsByRecipeId) ->
  if not includeAllDrinks
    return (recipe) -> ingredientSplitsByRecipeId[recipe.recipeId].missing.length == 0
  else
    return nofilter

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

_recipeListFilter = (listType, favoritedRecipeIds) ->
  return switch listType
    when 'all' then nofilter
    when 'favorites' then (recipe) -> _.contains favoritedRecipeIds, recipe.recipeId
    when 'custom' then (recipe) -> !!recipe.isCustom

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
  includeAllDrinks
  ingredientTags
  favoritedRecipeIds
  selectedRecipeList
}) ->
  searchTerm ?= ''
  baseLiquorFilter ?= definitions.ANY_BASE_LIQUOR

  assert ingredientsByTag
  assert recipes
  assert includeAllDrinks?
  assert ingredientTags
  assert favoritedRecipeIds
  assert selectedRecipeList

  ingredientSplits = ingredientSplitsByRecipeId { ingredientsByTag, recipes, ingredientTags }

  filteredRecipes = _.chain recipes
    .filter _baseLiquorFilter(baseLiquorFilter)
    .filter _mixabilityFilter(includeAllDrinks, ingredientSplits)
    .filter _recipeListFilter(selectedRecipeList, favoritedRecipeIds)
    .filter _searchTermFilter(searchTerm, ingredientsByTag)
    .value()

  return _sortAndGroupAlphabetical filteredRecipes

module.exports = _.extend filteredGroupedRecipes, {
  memoized : memoize filteredGroupedRecipes
  __test   : {
    _baseLiquorFilter
    _mixabilityFilter
    _searchTermFilter
    _recipeListFilter
    _sortAndGroupAlphabetical
  }
}

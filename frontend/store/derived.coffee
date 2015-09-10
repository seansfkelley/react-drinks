_   = require 'lodash'
log = require 'loglevel'

select = require './select'

definitions = require '../../shared/definitions'

RecipeSearch = require '../recipes/RecipeSearch'

searchedGroupedIngredients = ({
  groupedIngredients
  ingredientSearchTerm
}) ->
  if (ingredientSearchTerm?.trim() ? '') == ''
    return groupedIngredients
  else
    ingredientSearchTerm = ingredientSearchTerm.toLowerCase()

    filterBySearchTerm = (i) ->
      for term in i.searchable
        if term.indexOf(ingredientSearchTerm) != -1
          return true
      return false

    return _.chain groupedIngredients
      .map ({ name, ingredients }) ->
        ingredients = _.filter ingredients, filterBySearchTerm
        return { name, ingredients }
      .filter ({ ingredients }) -> ingredients.length > 0
      .value()

mixabilityForAllRecipes = ({
  ingredientsByTag
  alphabeticalRecipes
  selectedIngredientTags
}) ->
  recipeSearch = new RecipeSearch ingredientsByTag, alphabeticalRecipes
  return recipeSearch.computeMixabilityForAll _.keys(selectedIngredientTags)

mixabilityByRecipeId = ({
  ingredientsByTag
  alphabeticalRecipes
  selectedIngredientTags
}) ->
  mixableRecipes = mixabilityForAllRecipes { ingredientsByTag, alphabeticalRecipes, selectedIngredientTags }
  return _.extend {}, _.map(mixableRecipes, (recipes, missing) ->
    missing = +missing
    return _.reduce recipes, ((obj, r) -> obj[r.recipeId] = missing ; return obj), {}
  )...

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

filteredGroupedAlphabeticalRecipes = ({
  ingredientsByTag
  alphabeticalRecipes
  baseLiquorFilter
  recipeSearchTerm
  mixabilityFilters
  selectedIngredientTags
}) ->

  mixableRecipes = mixabilityForAllRecipes { ingredientsByTag, alphabeticalRecipes, selectedIngredientTags }
  mixabilityById = mixabilityByRecipeId { ingredientsByTag, alphabeticalRecipes, selectedIngredientTags }

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

  recipeSearch = new RecipeSearch ingredientsByTag, alphabeticalRecipes

  if recipeSearchTerm
    filteredRecipes = _nestedFilter filteredRecipes, (r) -> recipeSearch.recipeMatchesSearchTerm r, recipeSearchTerm

  return filteredRecipes

DERIVED_FUNCTIONS = {
  searchedGroupedIngredients
  mixabilityForAllRecipes
  mixabilityByRecipeId
  filteredGroupedAlphabeticalRecipes
}

STORE_SELECTORS = {
  searchedGroupedIngredients :
    groupedIngredients   : 'ingredients.groupedIngredients'
    ingredientSearchTerm : 'filters.ingredientSearchTerm'
  mixabilityForAllRecipes :
    ingredientsByTag       : 'ingredients.ingredientsByTag'
    alphabeticalRecipes    : 'recipes.alphabeticalRecipes'
    selectedIngredientTags : 'filters.selectedIngredientTags'
  mixabilityByRecipeId :
    ingredientsByTag       : 'ingredients.ingredientsByTag'
    alphabeticalRecipes    : 'recipes.alphabeticalRecipes'
    selectedIngredientTags : 'filters.selectedIngredientTags'
  filteredGroupedAlphabeticalRecipes :
    ingredientsByTag       : 'ingredients.ingredientsByTag'
    alphabeticalRecipes    : 'recipes.alphabeticalRecipes'
    baseLiquorFilter       : 'filters.baseLiquorFilter'
    recipeSearchTerm       : 'filters.recipeSearchTerm'
    mixabilityFilters      : 'filters.mixabilityFilters'
    selectedIngredientTags : 'filters.selectedIngredientTags'
}

destructuringMemoizedFunctions = _.mapValues STORE_SELECTORS, (selectorSpec, fnName) ->
  lastArg    = null
  lastResult = null

  return (state) ->
    arg = select state, selectorSpec
    if _.all arg, ((value, key) -> lastArg?[key] == value)
      return lastResult
    else
      lastArg = arg
      lastResult = DERIVED_FUNCTIONS[fnName](arg)
      return lastResult

module.exports = _.extend {
  __test : DERIVED_FUNCTIONS
}, destructuringMemoizedFunctions

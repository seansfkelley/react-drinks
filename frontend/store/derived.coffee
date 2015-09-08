_   = require 'lodash'
log = require 'loglevel'

RecipeSearch = require '../recipes/RecipeSearch'

searchedGroupedIngredients = (groupedIngredients, ingredientSearchTerm) ->
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

mixabilityForAllRecipes = (ingredientsByTag, alphabeticalRecipes, selectedIngredientTags) ->
  recipeSearch = new RecipeSearch ingredientsByTag, alphabeticalRecipes
  return recipeSearch.computeMixabilityForAll _.keys(selectedIngredientTags)

mixabilityByRecipeId = (ingredientsByTag, alphabeticalRecipes, selectedIngredientTags) ->
  mixableRecipes = mixabilityForAllRecipes ingredientsByTag, alphabeticalRecipes, selectedIngredientTags
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

# TODO: Shape assertions?...!
filteredGroupedAlphabeticalRecipes = (state) ->
  { ingredientsByTag } = state.ingredients
  { alphabeticalRecipes } = state.recipes
  { selectedIngredientTags
    baseLiquorFilter
    recipeSearchTerm
    mixabilityFilters } = state.filters

  mixableRecipes = mixabilityForAllRecipes ingredientsByTag, alphabeticalRecipes, selectedIngredientTags
  mixabilityById = mixabilityByRecipeId ingredientsByTag, alphabeticalRecipes, selectedIngredientTags

  filteredRecipes = _.chain allMixableRecipes
    .values()
    .flatten()
    .sortBy 'sortName'
    # group by should include a clause for numbers
    .groupBy (r) -> r.sortName[0].toLowerCase()
    .map (recipes, key) -> { recipes, key }
    .sortBy 'key'
    .value()

  if baseLiquorFilter and baseLiquorFilter != ANY_BASE_LIQUOR
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

module.exports = {
  searchedGroupedIngredients
  mixabilityForAllRecipes
  mixabilityByRecipeId
  filteredGroupedAlphabeticalRecipes
}

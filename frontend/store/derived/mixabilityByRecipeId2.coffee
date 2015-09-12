_   = require 'lodash'
log = require 'loglevel'

memoize = require './memoize'
assert  = require '../../../shared/tinyassert'

_countSubsetMissing = (small, large) ->
  missed = 0
  for s in small
    if s not in large
      missed++
  return missed

_includeAllGenerics = ({ ingredients, ingredientsByTag }) ->
  withGenerics = []

  for current in ingredients
    withGenerics.push current
    while current = ingredientsByTag[current.generic]
      withGenerics.push current

  return _.uniq withGenerics

_toMostGenericTags = ({ ingredients, ingredientsByTag }) ->
  return _.chain _includeAllGenerics({ ingredients, ingredientsByTag })
    .reject 'generic'
    .pluck 'tag'
    .uniq()
    .value()

_computeSubstitutionMap = ({ ingredients, ingredientsByTag }) ->
  ingredientsByTagWithGenerics = {}
  for i in ingredients
    generic = i
    (ingredientsByTagWithGenerics[generic.tag] ?= []).push i.tag
    while generic = ingredientsByTag[generic.generic]
      (ingredientsByTagWithGenerics[generic.tag] ?= []).push i.tag
  return ingredientsByTagWithGenerics

_generateSearchResult = ({ recipe, substitutionMap, ingredientsByTag }) ->
  missing    = []
  available  = []
  substitute = []

  for ingredient in recipe.ingredients
    if not ingredient.tag? # Things like 'water' are untagged.
      available.push ingredient
    else if substitutionMap[ingredient.tag]?
      available.push ingredient
    else
      currentTag = ingredient.tag
      while currentTag?
        if substitutionMap[currentTag]?
          substitute.push {
            need : ingredient
            have : _.map substitutionMap[currentTag], (t) => ingredientsByTag[t].display
          }
          break
        currentIngredient = ingredientsByTag[currentTag]
        if not currentIngredient?
          log.warn "recipe '#{recipe.name}' calls for or has a generic that calls for unknown tag '#{currentTag}'"
        currentTag = ingredientsByTag[currentIngredient?.generic]?.tag
      if not currentTag?
        missing.push ingredient

  return { recipeId : recipe.recipeId, missing, available, substitute }

mixabilityByRecipeId = ({ recipes, ingredientsByTag, ingredientTags }) ->
  assert recipes
  assert ingredientsByTag
  assert ingredientTags

  # Fucking hell I just want Set objects.
  if _.isPlainObject ingredientTags
    ingredientTags = _.keys ingredientTags

  exactlyAvailableIngredientsRaw = _.map ingredientTags, (tag) -> ingredientsByTag[tag]
  exactlyAvailableIngredients = _.compact exactlyAvailableIngredientsRaw
  if exactlyAvailableIngredientsRaw.length != exactlyAvailableIngredients.length
    extraneous = _.chain exactlyAvailableIngredientsRaw
      .map (value, i) => if not value? then ingredientTags[i]
      .compact()
      .value()
    log.warn "some tags that were searched are extraneous and will be ignored: #{JSON.stringify extraneous}"

  substitutionMap = _computeSubstitutionMap {
    ingredients : exactlyAvailableIngredients
    ingredientsByTag
  }
  allAvailableTagsWithGenerics = _.keys substitutionMap

  return _.chain recipes
    .map (r) =>
      indexableIngredients = _.chain r.ingredients
        .filter 'tag'
        .map (i) => ingredientsByTag[i.tag]
        .value()
      unknownIngredientAdjustment = indexableIngredients.length - _.compact(indexableIngredients).length
      mostGenericRecipeTags = _toMostGenericTags {
        ingredients : _.compact(indexableIngredients)
        ingredientsByTag
      }
      missingCount = _countSubsetMissing(
        mostGenericRecipeTags
        allAvailableTagsWithGenerics
      ) + unknownIngredientAdjustment
      return _generateSearchResult {
        recipe : r
        substitutionMap
        ingredientsByTag
      }
    .compact()
    .reduce ((obj, result) -> obj[result.recipeId] = _.omit(result, 'recipeId') ; return obj), {}
    .value()

module.exports = _.extend mixabilityByRecipeId, {
  __test : {
    _countSubsetMissing
    _includeAllGenerics
    _toMostGenericTags
    _computeSubstitutionMap
    _generateSearchResult
  }
  memoized : memoize mixabilityByRecipeId
}

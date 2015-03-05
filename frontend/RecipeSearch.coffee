_ = require 'lodash'

_countSubset = (small, large) ->
  missed = 0
  for s in small
    if s not in large
      missed++
  return missed

_generateSearchResult = (recipe, availableTags) ->
  missing    = []
  available  = []
  substitute = []

  for ingredient in recipe.ingredients
    if not ingredient.tag? # Things like 'water' are untagged.
      available.push ingredient
    else if ingredient.tag in availableTags
      available.push ingredient
    else if ingredient.genericTag in availableTags
      substitute.push ingredient
    else
      missing.push ingredient

  return _.defaults { missing, available, substitute }, recipe

class RecipeSearch
  constructor : (ingredients, @_recipes) ->
    @_ingredientForTag = {}
    for i in ingredients
      if i.tag?
        @_ingredientForTag[i.tag] = i

    for i in ingredients
      if i.generic? and not @_ingredientForTag[i.generic]?
        console.log "ingredient #{i.tag} refers to unknown generic #{i.generic}; inferring generic"
        @_ingredientForTag[i.generic] = {
          tag     : i.generic
          display : "[inferred] #{i.generic}"
        }

    return # for loop

  _includeAllGenerics : (ingredients) ->
    withGenerics = []

    for current in ingredients
      withGenerics.push current
      while current = @_ingredientForTag[current.generic]
        withGenerics.push current

    return _.uniq withGenerics

  _toMostGenericTags : (ingredients) ->
    return _.chain @_includeAllGenerics(ingredients)
      .reject 'generic'
      .pluck 'tag'
      .uniq()
      .value()

  computeMixableRecipes : (ingredientTags, fuzzyMatchThreshold = 0) ->
    exactlyAvailableIngredients  = _.map ingredientTags, (tag) => @_ingredientForTag[tag]
    allAvailableTagsWithGenerics = _.pluck @_includeAllGenerics(exactlyAvailableIngredients), 'tag'
    mostGenericAvailableTags     = @_toMostGenericTags exactlyAvailableIngredients

    return _.chain @_recipes
      .map (r) =>
        mostGenericRecipeTags = @_toMostGenericTags _.filter(r.ingredients, 'tag')
        if _countSubset(mostGenericRecipeTags, mostGenericAvailableTags) <= fuzzyMatchThreshold
          return _generateSearchResult r, allAvailableTagsWithGenerics
      .compact()
      .groupBy (result) -> result.missing.length
      .value()

module.exports = RecipeSearch

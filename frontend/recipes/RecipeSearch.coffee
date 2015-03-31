_   = require 'lodash'
log = require 'loglevel'

class RecipeSearch
  constructor : (ingredients, @_recipes) ->
    @_ingredientForTag = {}
    for i in ingredients
      if i.tag?
        @_ingredientForTag[i.tag] = i

    for i in ingredients
      if i.generic? and not @_ingredientForTag[i.generic]?
        log.trace "ingredient #{i.tag} refers to unknown generic #{i.generic}; inferring generic"
        @_ingredientForTag[i.generic] = {
          tag     : i.generic
          display : "[inferred] #{i.generic}"
        }

    return # for loop

  @_countSubsetMissing : (small, large) ->
    missed = 0
    for s in small
      if s not in large
        missed++
    return missed


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

  _generateSearchResult : (recipe, availableTags) ->
    missing    = []
    available  = []
    substitute = []

    for ingredient in recipe.ingredients
      if not ingredient.tag? # Things like 'water' are untagged.
        available.push ingredient
      else if ingredient.tag in availableTags
        available.push ingredient
      else if @_ingredientForTag[ingredient.tag]?.generic in availableTags
        substitute.push ingredient
      else
        missing.push ingredient

    return _.defaults { missing, available, substitute }, recipe

  computeMixableRecipes : (ingredientTags, fuzzyMatchThreshold = 0) ->
    exactlyAvailableIngredientsRaw = _.map ingredientTags, (tag) => @_ingredientForTag[tag]
    exactlyAvailableIngredients = _.compact exactlyAvailableIngredientsRaw
    if exactlyAvailableIngredientsRaw.length != exactlyAvailableIngredients.length
      log.warn "some tags that were searched are extraneous and will be ignored: #{JSON.stringify ingredientTags}"

    allAvailableTagsWithGenerics = _.pluck @_includeAllGenerics(exactlyAvailableIngredients), 'tag'
    mostGenericAvailableTags     = @_toMostGenericTags exactlyAvailableIngredients

    return _.chain @_recipes
      .map (r) =>
        indexableIngredients = _.chain r.ingredients
          .filter 'tag'
          .map (i) => @_ingredientForTag[i.tag]
          .value()
        unknownIngredientAdjustment = indexableIngredients.length - _.compact(indexableIngredients).length
        mostGenericRecipeTags = @_toMostGenericTags _.compact(indexableIngredients)
        missingCount = @constructor._countSubsetMissing(
          mostGenericRecipeTags
          mostGenericAvailableTags
        ) + unknownIngredientAdjustment
        if missingCount <= fuzzyMatchThreshold and missingCount < mostGenericRecipeTags.length
          return @_generateSearchResult r, allAvailableTagsWithGenerics
      .compact()
      .groupBy (result) -> result.missing.length
      .value()

module.exports = RecipeSearch

_          = require 'lodash'
$          = require 'jquery'
log        = require 'loglevel'
MicroEvent = require 'microevent'
Promise    = require 'bluebird'

normalization = require '../shared/normalization'

AppDispatcher = require './AppDispatcher'
RecipeSearch  = require './recipes/RecipeSearch'

class FluxStore
  MicroEvent.mixin this

  constructor : ->
    _.extend @, _.result(@, 'fields')

    @dispatchToken = AppDispatcher.register (payload) =>
      if this[payload.type]?
        this[payload.type](payload)
        @trigger 'change'

      return true

INGREDIENTS_KEY = 'drinks-app-ingredients'

IngredientStore = new class extends FluxStore
  fields : ->
    searchTerm                 : ''
    alphabeticalIngredients    : []
    allAlphabeticalIngredients : []
    groupedIngredients         : []
    searchedGroupedIngredients : []
    selectedIngredientTags     : JSON.parse(localStorage[INGREDIENTS_KEY] ? 'null') ? {}
    ingredientsByTag           : {}
    baseLiquors                : [ 'all', 'gin', 'vodka', 'whiskey', 'rum', 'brandy', 'tequila', 'liqueur' ]

  'set-ingredients' : ({ groupedIngredients, intangibleIngredients, alphabeticalIngredientTags }) ->
    @groupedIngredients = groupedIngredients

    ingredients = _.chain groupedIngredients
      .pluck 'ingredients'
      .flatten()
      .value()

    @ingredientsByTag = _.chain ingredients
      .filter (i) -> i.tag?
      .reduce ((map, i) -> map[i.tag] = i ; return map), {}
      .value()

    for i in intangibleIngredients
      @ingredientsByTag[i.tag] = i
      ingredients.push i

    for i in ingredients
      if i.generic? and not @ingredientsByTag[i.generic]?
        log.trace "ingredient #{i.tag} refers to unknown generic #{i.generic}; inferring generic"
        @ingredientsByTag[i.generic] = normalization.normalizeIngredient {
          tag     : i.generic
          display : "[inferred] #{i.generic}"
        }

    @allAlphabeticalIngredients = _.map alphabeticalIngredientTags, (t) => @ingredientsByTag[t]
    @alphabeticalIngredients = _.filter @allAlphabeticalIngredients, 'tangible'

    @_updateSearchedIngredients()

  'set-selected-ingredient-tags' : ({ selectedIngredientTags }) ->
    @selectedIngredientTags = selectedIngredientTags
    localStorage[INGREDIENTS_KEY] = JSON.stringify @selectedIngredientTags

  'search-ingredients' : ({ searchTerm }) ->
    @searchTerm = searchTerm.toLowerCase()
    @_updateSearchedIngredients()

  _updateSearchedIngredients : ->
    if @searchTerm == ''
      @searchedGroupedIngredients = @groupedIngredients
    else
      filterBySearchTerm = (i) =>
        for term in i.searchable
          if term.indexOf(@searchTerm) != -1
            return true
        return false

      @searchedGroupedIngredients = _.chain @groupedIngredients
        .map ({ name, ingredients }) ->
          ingredients = _.filter ingredients, filterBySearchTerm
          return { name, ingredients }
        .filter ({ ingredients }) -> ingredients.length > 0
        .value()

UI_LOCALSTORAGE_KEY   = 'drinks-app-ui'
UI_PERSISTABLE_FIELDS = [ 'mixabilityFilters', 'favoritedRecipes', 'baseLiquorFilter' ]

MIXABILITY_FILTER_RANGES = {
  mixable          : [ 0, 0 ]
  nearMixable      : [ 1, 2 ]
  notReallyMixable : [ 3, 100 ]
}

_toggleKey = (object, key) ->
  if object[key]
    delete object[key]
  else
    object[key] = true
  # Cooperate with PureRenderMixin.
  return _.clone object

UiStore = new class extends FluxStore
  fields : ->
    return _.extend {
      openIngredientGroups : {}
      favoritedRecipes     : {}
      baseLiquorFilter     : null
      mixabilityFilters    :
        mixable          : true
        nearMixable      : true
        notReallyMixable : false
    }, _.pick(JSON.parse(localStorage[UI_LOCALSTORAGE_KEY] ? '{}'), UI_PERSISTABLE_FIELDS)

  'toggle-mixability-filter' : ({ filter }) ->
    @mixabilityFilters = _.clone @mixabilityFilters
    @mixabilityFilters[filter] = not @mixabilityFilters[filter]
    @_persist()

  'set-base-liquor-filter' : ({ filter }) ->
    @baseLiquorFilter = filter
    @_persist()

  'toggle-ingredient-group' : ({ group }) ->
    if @openIngredientGroups[group]?
      @openIngredientGroups = {}
    else
      @openIngredientGroups = {}
      @openIngredientGroups[group] = true

  'toggle-favorite-recipe' : ({ recipeId }) ->
    @favoritedRecipes = _toggleKey @favoritedRecipes, recipeId
    @_persist()

  _persist : ->
    localStorage[UI_LOCALSTORAGE_KEY] = JSON.stringify _.pick(@, UI_PERSISTABLE_FIELDS)

FUZZY_MATCH = 2

RECIPE_LOCALSTORAGE_KEY   = 'drinks-app-recipes'
RECIPE_PERSISTABLE_FIELDS = 'customRecipes'

RecipeStore = new class extends FluxStore
  fields : ->
    return _.extend {
      searchTerm           : ''
      mixabilityByRecipeId : {}

      allRecipes     : []
      defaultRecipes : []
      customRecipes  : []

      alphabeticalRecipes         : []
      filteredAlphabeticalRecipes : []
    }, _.pick(JSON.parse(localStorage[RECIPE_LOCALSTORAGE_KEY] ? '{}'), RECIPE_PERSISTABLE_FIELDS)

  'set-ingredients' : ({ alphabetical, grouped }) ->
    @_updateDerivedRecipeLists()

  'set-default-recipes' : ({ recipes }) ->
    @defaultRecipes = recipes
    @_refreshRecipes()

  'set-selected-ingredient-tags' : ->
    @_updateDerivedRecipeLists()

  'toggle-mixability-filter' : ->
    @_updateDerivedRecipeLists()

  'set-base-liquor-filter' : ->
    @_updateDerivedRecipeLists()

  'search-recipes' : ({ searchTerm }) ->
    @searchTerm = searchTerm.toLowerCase().trim()
    @_updateSearchedRecipes()

  'save-recipe' : ({ recipe }) ->
    @customRecipes = @customRecipes.concat [ recipe ]
    @_refreshRecipes()
    @_persist()

  'delete-recipe' : ({ recipeId }) ->
    @customRecipes = _.reject @customRecipes, { recipeId }
    @_refreshRecipes()
    @_persist()

  _refreshRecipes : ->
    @allRecipes = @defaultRecipes.concat @customRecipes
    @_updateDerivedRecipeLists()

  _updateDerivedRecipeLists : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]

    alphabeticalRecipes = _.sortBy(@allRecipes, 'canonicalName')
    @_recipeSearch = new RecipeSearch IngredientStore.ingredientsByTag, alphabeticalRecipes

    @_updateMixableRecipes()
    @_updateSearchedRecipes()

  _updateMixableRecipes : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]

    selectedTags = _.keys IngredientStore.selectedIngredientTags
    allMixableRecipes = @_recipeSearch.computeMixabilityForAll selectedTags

    @alphabeticalRecipes = _.chain allMixableRecipes
      .map _.identity # map2array
      .flatten()
      .sortBy 'canonicalName'
      # group by should include a clause for numbers
      .groupBy (r) -> r.canonicalName[0].toLowerCase()
      .map (recipes, key) -> { recipes, key }
      .sortBy 'key'
      .value()

    @mixabilityByRecipeId = _.extend {}, _.map(allMixableRecipes, (recipes, missing) ->
      missing = +missing
      return _.reduce recipes, ((obj, r) -> obj[r.recipeId] = missing ; return obj), {}
    )...

    return # for loop

  _updateSearchedRecipes : ->
    AppDispatcher.waitFor [ UiStore.dispatchToken ]

    filteredRecipes = @alphabeticalRecipes

    if UiStore.baseLiquorFilter and UiStore.baseLiquorFilter != 'all'
      filteredRecipes = @_nestedFilter filteredRecipes, (r) ->
        if _.isString r.base
          return r.base == UiStore.baseLiquorFilter
        else if _.isArray r.base
          return UiStore.baseLiquorFilter in r.base
        else
          log.warn "recipe '#{r.name}' has a non-string, non-array base: #{r.base}"
          return false

    ranges = _.chain UiStore.mixabilityFilters
      .pick _.identity
      .map (_, f) -> MIXABILITY_FILTER_RANGES[f]
      .value()

    filteredRecipes = @_nestedFilter filteredRecipes, (r) =>
      for [ min, max ] in ranges
        if min <= @mixabilityByRecipeId[r.recipeId] <= max
          return true
      return false

    if @searchTerm
      filteredRecipes = @_nestedFilter filteredRecipes, (r) => @_recipeSearch.recipeMatchesSearchTerm r, @searchTerm

    @filteredAlphabeticalRecipes = filteredRecipes

  _nestedFilter : (list, filterFn) ->
    filteredList = []
    for { key, recipes } in list
      recipes = _.filter recipes, filterFn
      if recipes.length
        filteredList.push { key, recipes }
    return filteredList

  _persist : ->
    localStorage[RECIPE_LOCALSTORAGE_KEY] = JSON.stringify _.pick(@, RECIPE_PERSISTABLE_FIELDS)

Promise.resolve $.get('/ingredients')
.then (ingredients) =>
  AppDispatcher.dispatch _.extend {
    type : 'set-ingredients'
  }, ingredients

Promise.resolve $.get('/recipes')
.then (recipes) =>
  AppDispatcher.dispatch {
    type : 'set-default-recipes'
    recipes
  }

module.exports = {
  IngredientStore
  RecipeStore
  UiStore
}

_.extend (window.debug ?= {}), module.exports

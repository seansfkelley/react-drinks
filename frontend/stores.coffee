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
UI_PERSISTABLE_FIELDS = [ 'recipeFilters', 'favoritedRecipes' ]

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
      recipeFilters        : []
    }, _.pick(JSON.parse(localStorage[UI_LOCALSTORAGE_KEY] ? '{}'), UI_PERSISTABLE_FIELDS)

  'toggle-recipe-filter' : ({ filterType, filterValue }) ->
    filter = { type : filterType, value : filterValue }
    newRecipeFilters = _.reject @recipeFilters, filter
    if @recipeFilters.length == newRecipeFilters.length
      @recipeFilters = @recipeFilters.concat [ filter ]
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

      alphabeticalRecipes                 : []
      filteredSearchedAlphabeticalRecipes : []
    }, _.pick(JSON.parse(localStorage[RECIPE_LOCALSTORAGE_KEY] ? '{}'), RECIPE_PERSISTABLE_FIELDS)

  'set-ingredients' : ({ alphabetical, grouped }) ->
    @_updateDerivedRecipeLists()

  'set-default-recipes' : ({ recipes }) ->
    @defaultRecipes = recipes
    @_refreshRecipes()

  'set-selected-ingredient-tags' : ->
    @_updateDerivedRecipeLists()

  'toggle-recipe-filter' : ->
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
      if missing > FUZZY_MATCH
        missing = -1
      return _.reduce recipes, ((obj, r) -> obj[r.recipeId] = missing ; return obj), {}
    )...

    return # for loop

  _updateSearchedRecipes : ->
    if @searchTerm == ''
      searchedAlphabeticalRecipes = @alphabeticalRecipes
    else
      matchingRecipeIds = {}
      for r in @allRecipes
        matchingRecipeIds[r.recipeId] = @_recipeSearch.recipeMatchesSearchTerm r, @searchTerm
      searchedAlphabeticalRecipes = @_nestedFilter @alphabeticalRecipes, (r) -> matchingRecipeIds[r.recipeId]

    if not UiStore.recipeFilters.length
      @filteredSearchedAlphabeticalRecipes = searchedAlphabeticalRecipes
    else
      @filteredSearchedAlphabeticalRecipes = @_nestedFilter searchedAlphabeticalRecipes, (r) =>
        for f in UiStore.recipeFilters
          if f.type == 'mixability'
            return @mixabilityByRecipeId[r.recipeId] <= f.value
          else if f.type == 'base-liquor'
            return r.base == f.value
          else
            throw new Error 'unrecognized recipe filter', f

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

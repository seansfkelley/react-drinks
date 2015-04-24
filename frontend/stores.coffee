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
UI_PERSISTABLE_FIELDS = [ 'recipeSort', 'favoritedRecipes' ]

ORDERED_RECIPE_SORTS = [ 'alphabetical', 'mixable' ]
_nextSortOrder = (sortOrder) ->
  l = ORDERED_RECIPE_SORTS.length
  return ORDERED_RECIPE_SORTS[(_.indexOf(ORDERED_RECIPE_SORTS, sortOrder) + l + 1) % l]

UiStore = new class extends FluxStore
  fields : ->
    return _.extend {
      recipeSort           : 'alphabetical'
      openIngredientGroups : {}
      favoritedRecipes     : {}
    }, _.pick(JSON.parse(localStorage[UI_LOCALSTORAGE_KEY] ? '{}'), UI_PERSISTABLE_FIELDS)

  'toggle-recipe-sort' : ->
    @recipeSort = _nextSortOrder @recipeSort
    @_persist()

  'toggle-ingredient-group' : ({ group }) ->
    if @openIngredientGroups[group]?
      @openIngredientGroups = {}
    else
      @openIngredientGroups = {}
      @openIngredientGroups[group] = true

  'toggle-favorite-recipe' : ({ recipeId }) ->
    if @favoritedRecipes[recipeId]
      delete @favoritedRecipes[recipeId]
    else
      @favoritedRecipes[recipeId] = true
    # Cooperate with PureRenderMixin.
    @favoritedRecipes = _.clone @favoritedRecipes
    @_persist()

  _persist : ->
    localStorage[UI_LOCALSTORAGE_KEY] = JSON.stringify _.pick(@, UI_PERSISTABLE_FIELDS)

FUZZY_MATCH = 2

RECIPE_LOCALSTORAGE_KEY   = 'drinks-app-recipes'
RECIPE_PERSISTABLE_FIELDS = 'customRecipes'

RecipeStore = new class extends FluxStore
  fields : ->
    return _.extend {
      searchTerm                    : ''
      customRecipes                 : []

      allRecipes                    : []

      alphabeticalRecipes           : []
      # baseLiquorRecipes             : []
      mixableRecipes                : []

      searchedAlphabeticalRecipes   : []
      # searchedBaseLiquorRecipes     : []
      searchedMixableRecipes        : []

      mixabilityByRecipeId          : {}
    }, _.pick(JSON.parse(localStorage[RECIPE_LOCALSTORAGE_KEY] ? '{}'), RECIPE_PERSISTABLE_FIELDS)

  'set-ingredients' : ({ alphabetical, grouped }) ->
    @_updateDerivedRecipeLists()

  # The semantics here are iffy -- we should just be setting whatever we get. Split state up.
  'set-recipes' : ({ recipes }) ->
    @_setRecipes recipes.concat(@customRecipes)

  'set-selected-ingredient-tags' : ->
    @_updateDerivedRecipeLists()

  'search-recipes' : ({ searchTerm }) ->
    @searchTerm = searchTerm.toLowerCase().trim()
    @_updateSearchedRecipes()

  'save-recipe' : ({ recipe }) ->
    @customRecipes = @customRecipes.concat [ recipe ]
    @_setRecipes @allRecipes.concat(@customRecipes)
    @_persist()

  _setRecipes : (recipes) ->
    @allRecipes = recipes
    @_updateDerivedRecipeLists()

  _updateDerivedRecipeLists : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]

    alphabeticalRecipes = _.sortBy(@allRecipes, 'canonicalName')
    @_recipeSearch = new RecipeSearch IngredientStore.ingredientsByTag, alphabeticalRecipes

    @alphabeticalRecipes = _.chain alphabeticalRecipes
      # group by should include a clause for numbers
      .groupBy (r) -> r.canonicalName[0].toLowerCase()
      .map (recipes, key) -> { recipes, key }
      .sortBy 'key'
      .value()

    @_updateMixableRecipes()
    @_updateSearchedRecipes()

  _updateMixableRecipes : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]

    selectedTags = _.keys IngredientStore.selectedIngredientTags
    mixableRecipes = @_recipeSearch.computeMixableRecipes selectedTags, FUZZY_MATCH

    @mixableRecipes = _.chain mixableRecipes
      .map (recipes, missing) -> { recipes, key : +missing }
      .sortBy 'key'
      .value()
    # Should have a 'rest' key where we just dump all the other recipes?

    @mixabilityByRecipeId = _.extend {}, _.map(mixableRecipes, (recipes, missing) ->
      missing = +missing
      return _.reduce recipes, ((obj, r) -> obj[r.recipeId] = missing ; return obj), {}
    )...
    for { recipes } in @alphabeticalRecipes
      for r in recipes when not @mixabilityByRecipeId[r.recipeId]?
        @mixabilityByRecipeId[r.recipeId] = -1

    return # for loop

  _updateSearchedRecipes : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]

    BASE_LIST_NAMES = [ 'alphabetical', 'mixable' ]

    if @searchTerm == ''
      for baseList in BASE_LIST_NAMES
        @["searched#{_.capitalize(baseList)}Recipes"] = @["#{baseList}Recipes"]
    else
      matchingRecipeIds = {}
      for r in @allRecipes
        matchingRecipeIds[r.recipeId] = @_recipeSearch.recipeMatchesSearchTerm r, @searchTerm

      for baseList in BASE_LIST_NAMES
        srcList = @["#{baseList}Recipes"]
        dstList = @["searched#{_.capitalize(baseList)}Recipes"] = []
        for { key, recipes } in srcList
          recipes = _.filter recipes, (r) -> matchingRecipeIds[r.recipeId]
          if recipes.length
            dstList.push { key, recipes }

    return # for loop

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
    type : 'set-recipes'
    recipes
  }

module.exports = {
  IngredientStore
  RecipeStore
  UiStore
}

_.extend (window.debug ?= {}), module.exports

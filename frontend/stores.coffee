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

  'toggle-ingredient' : ({ tag }) ->
    if @selectedIngredientTags[tag]?
      delete @selectedIngredientTags[tag]
    else
      @selectedIngredientTags[tag] = true
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
UI_PERSISTABLE_FIELDS = [ 'useIngredients', 'favoritedRecipes' ]

UiStore = new class extends FluxStore
  fields : ->
    return _.extend {
      useIngredients       : true
      openIngredientGroups : {}
      favoritedRecipes     : {}
    }, _.pick(JSON.parse(localStorage[UI_LOCALSTORAGE_KEY] ? '{}'), UI_PERSISTABLE_FIELDS)

  'toggle-ingredient' : ->
    @useIngredients = true

  'toggle-use-ingredients' : ->
    @useIngredients = not @useIngredients
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
    @_persist()

  _persist : ->
    localStorage[UI_LOCALSTORAGE_KEY] = JSON.stringify _.pick(@, UI_PERSISTABLE_FIELDS)

FUZZY_MATCH = 2

RECIPE_LOCALSTORAGE_KEY   = 'drinks-app-recipes'
RECIPE_PERSISTABLE_FIELDS = 'customRecipes'

RecipeStore = new class extends FluxStore
  fields : ->
    # Should change this to have the fields:
    #   allRecipes (no stated ordering)
    #   searchedAlphabeticalRecipes
    #   searchedBaseLiquorRecipes
    #   searchedMixableRecipes
    # With each 'searched' being an ordered array of objects { key, recipes } where key is some
    # domain-specific key (i.e. the letter, the base liquor, or the mixability factor)
    return _.extend {
      searchTerm                    : ''
      alphabeticalRecipes           : []
      customRecipes                 : []
      groupedMixableRecipes         : []
      searchedAlphabeticalRecipes   : []
      searchedGroupedMixableRecipes : []
      mixabilityByRecipeId          : {}
    }, _.pick(JSON.parse(localStorage[RECIPE_LOCALSTORAGE_KEY] ? '{}'), RECIPE_PERSISTABLE_FIELDS)

  'set-ingredients' : ({ alphabetical, grouped }) ->
    @_createRecipeSearch()
    @_updateDerivedRecipeLists()

  # The semantics here are iffy -- we should just be setting whatever we get. Split state up.
  'set-recipes' : ({ recipes }) ->
    @_setRecipes recipes.concat(@customRecipes)

  'toggle-ingredient' : ->
    @_updateDerivedRecipeLists()

  'search-recipes' : ({ searchTerm }) ->
    @searchTerm = searchTerm.toLowerCase().trim()
    @_updateSearchedRecipes()

  'save-recipe' : ({ recipe }) ->
    @customRecipes.push recipe
    @_setRecipes @alphabeticalRecipes.concat([ recipe ])
    @_persist()

  _setRecipes : (recipes) ->
    @alphabeticalRecipes = _.sortBy(recipes, 'canonicalName')
    @_createRecipeSearch()
    @_updateDerivedRecipeLists()

  _createRecipeSearch : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]
    @_recipeSearch = new RecipeSearch IngredientStore.ingredientsByTag, @alphabeticalRecipes

  _updateDerivedRecipeLists : ->
    @_updateMixableRecipes()
    @_updateSearchedRecipes()

  _updateMixableRecipes : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]
    selectedTags = _.keys IngredientStore.selectedIngredientTags
    mixableRecipes = @_recipeSearch.computeMixableRecipes selectedTags, FUZZY_MATCH
    @groupedMixableRecipes = _.map mixableRecipes, (recipes, missing) ->
      missing = +missing
      name = switch missing
        when 0 then 'Mixable Drinks'
        when 1 then 'With 1 More Ingredient'
        else "With #{missing} More Ingredients"
      recipes = _.sortBy recipes, 'name'
      return { name, recipes, missing }

    @mixabilityByRecipeId = _.extend _.map(mixableRecipes, (recipes, missing) ->
      missing = +missing
      return _.reduce recipes, ((obj, r) -> obj[r.recipeId] = missing ; return obj), {}
    )...
    for r in @alphabeticalRecipes when not @mixabilityByRecipeId[r.recipeId]?
      @mixabilityByRecipeId[r.recipeId] = -1

  _updateSearchedRecipes : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]
    if @searchTerm == ''
      @searchedAlphabeticalRecipes   = @alphabeticalRecipes
      @searchedGroupedMixableRecipes = @groupedMixableRecipes
    else
      filterRecipe = (r) => @_recipeSearch.recipeMatchesSearchTerm r, @searchTerm

      @searchedAlphabeticalRecipes = _.filter @alphabeticalRecipes, filterRecipe
      @searchedGroupedMixableRecipes = _.chain @groupedMixableRecipes
        .map (group) =>
          return _.defaults {
            recipes : _.filter group.recipes, filterRecipe
          }, group
        .filter ({ recipes }) -> recipes.length > 0
        .value()

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

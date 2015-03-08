_          = require 'lodash'
$          = require 'jquery'
MicroEvent = require 'microevent'
Promise    = require 'bluebird'

AppDispatcher = require './AppDispatcher'
RecipeSearch   = require './RecipeSearch'

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
    alphabeticalIngredients : []
    groupedIngredients      : []
    selectedIngredientTags  : JSON.parse(localStorage[INGREDIENTS_KEY] ? 'null') ? {}

  'set-ingredients' : ({ alphabetical, grouped }) ->
    @alphabeticalIngredients = alphabetical
    @groupedIngredients      = grouped

  'toggle-ingredient' : ({ tag }) ->
    if @selectedIngredientTags[tag]?
      delete @selectedIngredientTags[tag]
    else
      @selectedIngredientTags[tag] = true
    localStorage[INGREDIENTS_KEY] = JSON.stringify @selectedIngredientTags

UiStore = new class extends FluxStore
  fields : ->
    useIngredients       : false
    openIngredientGroups : {}

  'toggle-use-ingredients' : ->
    @useIngredients = not @useIngredients

  'toggle-ingredient-group' : ({ group }) ->
    if @openIngredientGroups[group]?
      delete @openIngredientGroups[group]
    else
      @openIngredientGroups[group] = true

FUZZY_MATCH = 2

RecipeStore = new class extends FluxStore
  fields : ->
    searchTerm                    : ''
    alphabeticalRecipes           : []
    groupedMixableRecipes         : []
    searchedAlphabeticalRecipes   : []
    searchedGroupedMixableRecipes : []

  'set-ingredients' : ({ alphabetical, grouped }) ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]
    @_createRecipeSearch()
    @_updateDerivedRecipeLists()

  'set-recipes' : ({ recipes }) ->
    @alphabeticalRecipes = recipes
    @_createRecipeSearch()
    @_updateDerivedRecipeLists()

  'toggle-ingredient' : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]
    @_updateDerivedRecipeLists()

  'search-recipes' : ({ searchTerm }) ->
    @searchTerm = searchTerm.toLowerCase()
    @_updateSearchedRecipes()

  _createRecipeSearch : ->
    @_recipeSearch = new RecipeSearch IngredientStore.alphabeticalIngredients, @alphabeticalRecipes

  _updateDerivedRecipeLists : ->
    @_updateMixableRecipes()
    @_updateSearchedRecipes()

  _updateMixableRecipes : ->
    selectedTags = _.keys IngredientStore.selectedIngredientTags
    mixableRecipes = @_recipeSearch.computeMixableRecipes selectedTags, FUZZY_MATCH
    @groupedMixableRecipes = _.map mixableRecipes, (recipes, missingCount) ->
      name = switch +missingCount
        when 0 then 'Mixable Drinks'
        when 1 then 'With 1 More Ingredient'
        else "With #{missingCount} More Ingredients"
      recipes = _.sortBy recipes, 'name'
      return { name, recipes }

  _updateSearchedRecipes : ->
    if @searchTerm == ''
      @searchedAlphabeticalRecipes   = @alphabeticalRecipes
      @searchedGroupedMixableRecipes = @groupedMixableRecipes
    else
      filterBySearchTerm = (r) => r.name.toLowerCase().indexOf(@searchTerm) != -1
      @searchedAlphabeticalRecipes = _.filter @alphabeticalRecipes, filterBySearchTerm
      @searchedGroupedMixableRecipes = _.chain @groupedMixableRecipes
        .map ({ name, recipes }) ->
          recipes = _.filter recipes, filterBySearchTerm
          return { name, recipes }
        .filter ({ recipes }) -> recipes.length > 0
        .value()


Promise.resolve $.get('/ingredients')
.then ({ alphabetical, grouped }) =>
  AppDispatcher.dispatch {
    type : 'set-ingredients'
    alphabetical
    grouped
  }

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

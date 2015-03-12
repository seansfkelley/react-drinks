_          = require 'lodash'
$          = require 'jquery'
MicroEvent = require 'microevent'
Promise    = require 'bluebird'

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
    groupedIngredients         : []
    searchedGroupedIngredients : []
    selectedIngredientTags     : JSON.parse(localStorage[INGREDIENTS_KEY] ? 'null') ? {}

  'set-ingredients' : ({ groupedIngredients }) ->
    @groupedIngredients = groupedIngredients
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
UI_PERSISTABLE_FIELDS = [ 'useIngredients', 'openIngredientGroups' ]

UiStore = new class extends FluxStore
  fields : ->
    return _.extend {
      useIngredients       : false
      openIngredientGroups : {}
      favoritedRecipes     : {}
    }, JSON.parse(localStorage[UI_LOCALSTORAGE_KEY] ? 'null')

  'toggle-use-ingredients' : ->
    @useIngredients = not @useIngredients
    @_persist()

  'toggle-ingredient-group' : ({ group }) ->
    if @openIngredientGroups[group]?
      delete @openIngredientGroups[group]
    else
      @openIngredientGroups[group] = true
    @_persist()

  'toggle-favorite-recipe' : ({ normalizedName }) ->
    if @favoritedRecipes[normalizedName]
      delete @favoritedRecipes[normalizedName]
    else
      @favoritedRecipes[normalizedName] = true
    @_persist()

  _persist : ->
    localStorage[UI_LOCALSTORAGE_KEY] = JSON.stringify _.pick(@, UI_PERSISTABLE_FIELDS)

FUZZY_MATCH = 2

RecipeStore = new class extends FluxStore
  fields : ->
    searchTerm                    : ''
    alphabeticalRecipes           : []
    groupedMixableRecipes         : []
    searchedAlphabeticalRecipes   : []
    searchedGroupedMixableRecipes : []

  'set-ingredients' : ({ alphabetical, grouped }) ->
    @_createRecipeSearch()
    @_updateDerivedRecipeLists()

  'set-recipes' : ({ recipes }) ->
    @alphabeticalRecipes = recipes
    @_createRecipeSearch()
    @_updateDerivedRecipeLists()

  'toggle-ingredient' : ->
    @_updateDerivedRecipeLists()

  'search-recipes' : ({ searchTerm }) ->
    @searchTerm = searchTerm.toLowerCase()
    @_updateSearchedRecipes()

  _createRecipeSearch : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]
    ingredients = _.chain IngredientStore.groupedIngredients
      .pluck 'ingredients'
      .flatten()
      .value()
    @_recipeSearch = new RecipeSearch ingredients, @alphabeticalRecipes

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

  _updateSearchedRecipes : ->
    if @searchTerm == ''
      @searchedAlphabeticalRecipes   = @alphabeticalRecipes
      @searchedGroupedMixableRecipes = @groupedMixableRecipes
    else
      filterBySearchTerm = (r) => r.name.toLowerCase().indexOf(@searchTerm) != -1
      @searchedAlphabeticalRecipes = _.filter @alphabeticalRecipes, filterBySearchTerm
      @searchedGroupedMixableRecipes = _.chain @groupedMixableRecipes
        .map (group) ->
          return _.defaults {
            recipes : _.filter group.recipes, filterBySearchTerm
          }, group
        .filter ({ recipes }) -> recipes.length > 0
        .value()


Promise.resolve $.get('/ingredients')
.then (groupedIngredients) =>
  AppDispatcher.dispatch {
    type : 'set-ingredients'
    groupedIngredients
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

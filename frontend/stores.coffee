AppDispatcher = require './AppDispatcher'

class FluxStore
  MicroEvent.mixin @::

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

RecipeStore = new class extends FluxStore
  fields : ->
    allRecipes            : []
    groupedMixableRecipes : []

  'set-recipes' : ({ recipes }) ->
    @allRecipes = recipes
    @_updateMixableRecipes()

  'toggle-ingredient' : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]
    @_updateMixableRecipes()

  _updateMixableRecipes : ->
    @groupedMixableRecipes = [
      name    : 'group 1'
      recipes : @allRecipes
    ]

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
}

_.extend (window.debug ?= {}), module.exports

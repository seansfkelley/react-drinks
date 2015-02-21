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
    allIngredients         : []
    selectedIngredientTags : JSON.parse(localStorage[INGREDIENTS_KEY] ? 'null') ? {}

  'set-all-ingredients' : ({ ingredients }) ->
    @allIngredients = ingredients

  'toggle-ingredient' : ({ tag }) ->
    if @selectedIngredientTags[tag]?
      delete @selectedIngredientTags[tag]
    else
      @selectedIngredientTags[tag] = true
    localStorage[INGREDIENTS_KEY] = JSON.stringify @selectedIngredientTags

Promise.resolve $.get('/ingredients')
.then (ingredients) =>
  AppDispatcher.dispatch {
    type : 'set-all-ingredients'
    ingredients
  }
.catch (e) =>
  console.error e

module.exports = {
  IngredientStore
}

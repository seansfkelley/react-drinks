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
    filteredIngredients    : []
    selectedIngredientTags : JSON.parse(localStorage[INGREDIENTS_KEY] ? 'null') ? {}
    filterTerm             : ''

  _filter : ->
    @filteredIngredients = _.filter @allIngredients, (i) =>
      return _.contains i.display.toLowerCase(), @filterTerm.toLowerCase()

  'set-all-ingredients' : ({ ingredients }) ->
    @allIngredients = ingredients
    @_filter()

  'set-filter-term' : ({ filterTerm }) ->
    @filterTerm = filterTerm
    @_filter()

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

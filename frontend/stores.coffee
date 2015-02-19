AppDispatcher = require './AppDispatcher.coffee'

class FluxStore
  MicroEvent.mixin @::

  constructor : ->
    _.extend @, _.result(@, 'fields')

    @dispatchToken = AppDispatcher.register (payload) =>
      if this[payload.type]?
        this[payload.type](payload)
        @trigger 'change'

      return true

IngredientStore = new class extends FluxStore
  fields : ->
    allIngredients         : []
    filteredIngredients    : []
    selectedIngredientTags : {}
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

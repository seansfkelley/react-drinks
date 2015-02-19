class window.FluxStore
  MicroEvent.mixin @::

  constructor : ->
    _.extend @, _.result(@, 'fields')

    @dispatchToken = AppDispatcher.register (payload) =>
      if this[payload.type]?
        this[payload.type](payload)
        @trigger 'change'

      return true

window.IngredientStore = new class extends FluxStore
  fields : ->
    allIngredients      : []
    filteredIngredients : []
    filterTerm          : ''

  _filter : ->
    @filteredIngredients = _.filter @allIngredients, (i) =>
      return _.contains i.display.toLowerCase(), @filterTerm

  'set-all-ingredients' : ({ ingredients }) ->
    @allIngredients = ingredients
    @_filter()

  'set-filter-term' : ({ filterTerm }) ->
    @filterTerm = filterTerm
    @_filter()

Promise.resolve $.get('/ingredients')
.then (ingredients) =>
  AppDispatcher.dispatch {
    type : 'set-all-ingredients'
    ingredients
  }
.catch (e) =>
  console.error e

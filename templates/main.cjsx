# @cjsx React.DOM

AppDispatcher = new Flux.Dispatcher

IngredientStore =
  allIngredients      : []
  filteredIngredients : []
  filterTerm          : ''

  _filter : ->
    @filteredIngredients = _.filter @allIngredients, (i) =>
      return _.contains i.display.toLowerCase(), @filterTerm

MicroEvent.mixin IngredientStore

IngredientStore.dispatchToken = AppDispatcher.register (payload) ->
  switch payload.type
  when 'set-all-ingredients'
    IngredientStore.allIngredients = payload.ingredients
    IngredientStore._filter()
  when 'set-filter-term'
    IngredientStore.filterTerm = payload.filterTerm
    IngredientStore._filter()
  else
    return true

  IngredientStore.trigger 'change'
  return true

Promise.resolve $.get(@props.url)
.then (ingredients) =>
  AppDispatcher.dispatch {
    type : 'set-all-ingredients'
    ingredients
  }
.catch (e) =>
  console.error @props.url, e

Ingredient = React.createClass {
  render : ->
    <div className='ingredient'>
      <div className='name'>{@props.name}</div>
    </div>
}

IngredientSearch = React.createClass {
  getInitialState : ->
    return _.pick IngredientStore, 'filterTerm'

  componentDidMount : ->
    IngredientStore.bind 'change', @_onChange

  componentWillUnmount : ->
    IngredientStore.unbind 'change', @_onChange

  _onChange : ->
    @setState _.pick(IngredientStore, 'filterTerm')

  render : ->
    <div className='list-filter'>
      <input type='text' placeholder={@props.placeholder} value={@state.filterTerm} onChange={@_setFilterTerm}/>
    </div>

  _setFilterTerm : (e) ->
    AppDispatcher.dispatch {
      type       : 'set-filter-term'
      filterTerm : e.target.value
    }
}

IngredientList = React.createClass {
  getInitialState : ->
    return _.pick IngredientStore, 'filteredIngredients'

  componentDidMount : ->
    IngredientStore.bind 'change', @_onChange

  componentWillUnmount : ->
    IngredientStore.unbind 'change', @_onChange

  _onChange : ->
    @setState _.pick(IngredientStore, 'filteredIngredients')

  render : ->
    ingredientNodes = @state.filteredIngredients.map (ingredient) ->
      return <Ingredient name={ingredient.display} key={ingredient.tag}/>

    <div className='searchable-list'>
      <IngredientSearch/>
      <div className='list-items'>
        {ingredientNodes}
      </div>
    </div>
}

React.render <IngredientList/>, $('body')[0]

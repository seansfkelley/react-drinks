# @cjsx React.DOM

Ingredient = React.createClass {
  render : ->
    <div className='ingredient'>
      <div className='name'>{@props.name}</div>
    </div>
}

IngredientSearch = React.createClass {
  getInitialState : -> { searchTerm : '' }

  render : ->
    <div className='list-filter'>
      <input type='text' placeholder={@props.placeholder} value={@state.searchTerm} onChange={@_onChange}/>
    </div>

  _onChange : (e) ->
    @setState { searchTerm : e.target.value }
    @props.onSearchChange?(e.target.value)
}

IngredientList = React.createClass {
  getInitialState : ->
    return {
      filteredIngredients : []
      allIngredients      : []
    }

  componentDidMount : ->
    Promise.resolve $.get(@props.url)
    .then (ingredients) =>
      @setState {
        filteredIngredients : ingredients
        allIngredients      : ingredients
      }
    .catch (e) =>
      console.error @props.url, e

  render : ->
    ingredientNodes = @state.filteredIngredients.map (ingredient) ->
      return <Ingredient name={ingredient.display} key={ingredient.tag}/>

    <div className='searchable-list'>
      <IngredientSearch onSearchChange={@_onSearchChange}/>
      <div className='list-items'>
        {ingredientNodes}
      </div>
    </div>

  _onSearchChange : (searchTerm) ->
    searchTerm = searchTerm.toLowerCase()
    filteredIngredients = _.filter @state.allIngredients, (i) ->
      return _.contains i.display.toLowerCase(), searchTerm
    @setState { filteredIngredients }
}

React.render <IngredientList url='/ingredients' />, $('body')[0]

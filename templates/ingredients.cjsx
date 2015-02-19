# @cjsx React.DOM

Ingredient = React.createClass {
  render : ->
    <div className='ingredient'>
      <div className='name'>{@props.name}</div>
    </div>
}

IngredientSearch = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'filterTerm'
  ]

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
  mixins : [
    FluxMixin IngredientStore, 'filteredIngredients'
  ]

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

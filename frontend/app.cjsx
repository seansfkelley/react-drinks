# @cjsx React.DOM

React = require 'react'

FluxMixin           = require './FluxMixin.coffee'
AppDispatcher       = require './AppDispatcher.coffee'
{ IngredientStore } = require './stores.coffee'

Ingredient = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'selectedIngredientTags'
  ]

  render : ->
    className = 'ingredient'
    if @state.selectedIngredientTags[@props.tag]
      className += ' is-selected'

    <div className={className} onClick={@_toggleIngredient}>
      <div className='name'>{@props.name}</div>
    </div>

  _toggleIngredient : ->
    AppDispatcher.dispatch {
      type : 'toggle-ingredient'
      tag  : @props.tag
    }
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
      return <Ingredient name={ingredient.display} tag={ingredient.tag} key={ingredient.tag}/>

    <div className='searchable-list'>
      <IngredientSearch/>
      <div className='list-items'>
        {ingredientNodes}
      </div>
    </div>
}

React.render <IngredientList/>, $('body')[0]

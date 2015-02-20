# @cjsx React.DOM

React = require 'react'

FluxMixin           = require './FluxMixin'
AppDispatcher       = require './AppDispatcher'
{ IngredientStore } = require './stores'

Ingredient = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'selectedIngredientTags'
  ]

  render : ->
    className = 'ingredient'
    if @state.selectedIngredientTags[@props.tag]
      className += ' is-selected'

    <div className={className} onTouchTap={@_toggleIngredient}>
      <div className='name'>{@props.name}</div>
    </div>

  _toggleIngredient : ->
    AppDispatcher.dispatch {
      type : 'toggle-ingredient'
      tag  : @props.tag
    }
}

ListHeader = React.createClass {
  render : ->
    <div className='sticky-list-header'>{@props.title}</div>
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
    lastTitle = null
    ingredientNodes = _.chain @state.filteredIngredients
      .map (ingredient) ->
        firstLetter = ingredient.display[0].toUpperCase()
        if firstLetter != lastTitle
          elements = [ <ListHeader title={firstLetter}/> ]
          lastTitle = firstLetter
        else
          elements = []

        return elements.concat [
          <Ingredient name={ingredient.display} tag={ingredient.tag} key={ingredient.tag}/>
        ]
      .flatten()
      .value()

    <div className='ingredient-list' onScroll={@_onScroll}>
      <IngredientSearch/>
      <div className='list-items'>
        {ingredientNodes}
      </div>
    </div>

  _onScroll : console.log.bind(console)
}

React.render <IngredientList/>, $('body')[0]

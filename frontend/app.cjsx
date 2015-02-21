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
    iconClassName = 'ingredient-icon fa'
    selected = @state.selectedIngredientTags[@props.tag]

    if selected
      className += ' is-selected'
      # This icon is pretty shit, but at least it has an accompanying empty form.
      iconClassName += ' fa-check-circle-o'
    else
      iconClassName += ' fa-circle-o'

    <div className={className} onTouchTap={@_toggleIngredient}>
      <i className={iconClassName}/>
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

IngredientList = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'allIngredients'
  ]

  render : ->
    lastTitle = null
    ingredientNodes = _.chain @state.allIngredients
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
      {ingredientNodes}
    </div>

  _onScroll : console.log.bind(console)
}

React.render <IngredientList/>, $('body')[0]

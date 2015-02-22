# @cjsx React.DOM

React = require 'react'

FluxMixin           = require './FluxMixin'
AppDispatcher       = require './AppDispatcher'
{ IngredientStore } = require './stores'

TabbedView = require './TabbedView'

IngredientListItem = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'selectedIngredientTags'
  ]

  render : ->
    className = 'ingredient'
    iconClassName = 'ingredient-icon fa'

    if @state.selectedIngredientTags[@props.ingredient.tag]
      className += ' is-selected'
      # This icon is pretty shit, but at least it has an accompanying empty form.
      iconClassName += ' fa-check-circle-o'
    else
      iconClassName += ' fa-circle-o'

    <div className={className} onTouchTap={@_toggleIngredient}>
      <i className={iconClassName}/>
      <div className='name'>{@props.ingredient.display}</div>
    </div>

  _toggleIngredient : ->
    AppDispatcher.dispatch {
      type : 'toggle-ingredient'
      tag  : @props.ingredient.tag
    }
}

ListHeader = React.createClass {
  render : ->
    <div className='list-header'>{@props.title}</div>
}

AlphabeticalIngredientList = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'alphabeticalIngredients'
  ]

  render : ->
    lastTitle = null
    ingredientNodes = _.chain @state.alphabeticalIngredients
      .map (ingredient) ->
        firstLetter = ingredient.display[0].toUpperCase()
        if firstLetter != lastTitle
          elements = [ <ListHeader title={firstLetter}/> ]
          lastTitle = firstLetter
        else
          elements = []

        return elements.concat [
          <IngredientListItem ingredient={ingredient} key={ingredient.tag}/>
        ]
      .flatten()
      .value()

    <div className='ingredient-list alphabetical'>
      {ingredientNodes}
    </div>
}

GroupedIngredientList = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'groupedIngredients'
  ]

  render : ->
    ingredientNodes = _.chain @state.groupedIngredients
      .map ({ name, ingredients }) ->
        return [
          <ListHeader title={name}/>
          _.map ingredients, (ingredient) ->
            <IngredientListItem ingredient={ingredient} key={ingredient.tag}/>
        ]
      .flatten()
      .value()

    <div className='ingredient-list grouped'>
      {ingredientNodes}
    </div>
}

tabs = [
  icon    : 'glass'
  title   : 'By Name'
  content : <AlphabeticalIngredientList/>
,
  icon    : 'glass'
  title   : 'By Group'
  content : <GroupedIngredientList/>
]

IngredientSelectionPage = React.createClass {
  render : ->
    <TabbedView tabs={tabs}/>
}

module.exports = IngredientSelectionPage

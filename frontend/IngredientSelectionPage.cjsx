# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin           = require './FluxMixin'
AppDispatcher       = require './AppDispatcher'
{ IngredientStore } = require './stores'

TabbedView = require './TabbedView'
ListHeader = require './ListHeader'

IngredientListItem = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'selectedIngredientTags'
  ]

  render : ->
    className = 'ingredient-list-item list-item'
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
          elements = [ <ListHeader title={firstLetter} key={'header-' + firstLetter} ref={'header-' + firstLetter}/> ]
          lastTitle = firstLetter
        else
          elements = []

        return elements.concat [
          <IngredientListItem ingredient={ingredient} key={ingredient.tag}/>
        ]
      .flatten()
      .value()

    <div className='sticky-header-container'>
      {if @state.stickyHeaderTitle?
        <div className='sticky-header-wrapper' style={{ marginTop : @state.stickyHeaderOffset }}>
          <ListHeader title={@state.stickyHeaderTitle}/>
        </div>}
      <div className='ingredient-list alphabetical' onScroll={@_onScroll}>
        {ingredientNodes}
      </div>
    </div>

  _onScroll : (e) ->
    scrollTop = @getDOMNode().getBoundingClientRect().top
    refTopPairs = _.chain(@refs)
      .filter (_, refName) -> refName[...7] == 'header-'
      .map (ref) -> [ ref, ref.getDOMNode().getBoundingClientRect().top - scrollTop ]
      .sortBy ([ ref, top ]) -> top
      .value()

    for [ ref, top ], i in refTopPairs
      if top > 0
        previous = refTopPairs[i - 1]
        current  = refTopPairs[i]
        break

    if previous? and current?
      @setState {
        stickyHeaderTitle  : previous[0].props.title
        stickyHeaderOffset : Math.min (current[1] - current[0].getDOMNode().getBoundingClientRect().height), 0
      }
    else
      @setState {
        stickyHeaderTitle  : null
        stickyHeaderOffset : 0
      }
}

GroupedIngredientList = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'groupedIngredients'
  ]

  render : ->
    ingredientNodes = _.chain @state.groupedIngredients
      .map ({ name, ingredients }) ->
        return [
          <ListHeader title={name} key={'header-' + name}/>
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

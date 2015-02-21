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

TabBar = React.createClass {
  render : ->
    tabs = @props.tabs.map (t) =>
      tabClass = 'tab'
      if @props.active == t
        tabClass += ' active'
      <div className={tabClass} onClick={_.partial @props.onTabSelect, t}>
        <i className={'fa fa-' + t.icon}/>
        {t.title}
      </div>

    <div className='tab-container'>
      {tabs}
    </div>
}

TabbedView = React.createClass {
  getInitialState : ->
    return {
      active : @props.tabs[0]
    }

  render : ->
    <div className='tabbed-view'>
      <TabBar tabs={@props.tabs} active={@state.active} onTabSelect={@_onTabSelect}/>
      {@state.active.content}
    </div>

  _onTabSelect : (active) ->
    @setState { active }
}

ListHeader = React.createClass {
  render : ->
    <div className='sticky-list-header'>{@props.title}</div>
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
          <Ingredient name={ingredient.display} tag={ingredient.tag} key={ingredient.tag}/>
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
      .map (ingredients, group) ->
        return [
          <ListHeader title={group}/>
          _.map ingredients, (ingredient) ->
            <Ingredient name={ingredient.display} tag={ingredient.tag} key={ingredient.tag}/>
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

React.render <TabbedView tabs={tabs}/>, document.body

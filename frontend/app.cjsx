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

    <div className='tab-bar'>
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
      .map ({ name, ingredients }) ->
        return [
          <ListHeader title={name}/>
          _.map ingredients, (ingredient) ->
            <Ingredient name={ingredient.display} tag={ingredient.tag} key={ingredient.tag}/>
        ]
      .flatten()
      .value()

    <div className='ingredient-list grouped'>
      {ingredientNodes}
    </div>
}

SegmentedViewHeader = React.createClass {
  render : ->
    leftControlClasses = 'segment-control left'
    if @props.index == 0
      leftControlClasses += ' hidden'

    rightControlClasses = 'segment-control right'
    if @props.index == @props.segments.length - 1
      rightControlClasses += ' hidden'

    <div className='segmented-bar'>
      <div className={leftControlClasses} onClick={@_onControlClick.bind(this, 'left')}>
        <i className='fa fa-chevron-left'/>
      </div>
      <div className='segment-title'>{@props.segments[@props.index].title}</div>
      <div className={rightControlClasses} onClick={@_onControlClick.bind(this, 'right')}>
        <i className='fa fa-chevron-right'/>
      </div>
    </div>

  _onControlClick : (direction) ->
    if direction == 'left'
      @props.setIndex @props.index - 1
    else
      @props.setIndex @props.index + 1
}

SegmentedView = React.createClass {
  getInitialState : ->
    return {
      index : 0
    }

  render : ->
    <div className='segmented-view'>
      <SegmentedViewHeader setIndex={@_setIndex} index={@state.index} segments={@props.segments}/>
      {@props.segments[@state.index].content}
    </div>

  _setIndex : (index) ->
    @setState { index }
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

segments = [
  title : 'Ingredients'
  content : <TabbedView tabs={tabs}/>
,
  title : 'Recipes'
  content : <div/>
]

segmentedView = <SegmentedView segments={segments}/>

React.render segmentedView, document.body

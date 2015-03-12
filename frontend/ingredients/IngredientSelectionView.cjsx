# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../FluxMixin'
AppDispatcher = require '../AppDispatcher'

{ IngredientStore, UiStore } = require '../stores'

FixedHeaderFooter = require '../components/FixedHeaderFooter'
HeaderWithSearch  = require '../components/HeaderWithSearch'

IngredientSelectionHeader = React.createClass {
  displayName : 'IngredientSelectionHeader'

  render : ->
    <HeaderWithSearch
      leftIcon='fa-times-circle'
      leftIconOnTouchTap={@_hideIngredients}
      title='Ingredients'
      onSearch={@_setSearchTerm}
    />

  # In the future, this should pop up a loader and then throttle the number of filters performed.
  _setSearchTerm : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-ingredients'
      searchTerm
    }

  _hideIngredients : ->
    AppDispatcher.dispatch {
      type : 'hide-flyup'
    }
}

IngredientGroupHeader = React.createClass {
  displayName : 'IngredientGroupHeader'

  render : ->
    text = @props.groupName
    if @props.selectedCount > 0
      text += " (#{@props.selectedCount})"
    <div className='ingredient-group-header' onTouchTap={@_toggleGroup}>
      <span>{text}</span>
    </div>

  _toggleGroup : ->
    AppDispatcher.dispatch {
      type  : 'toggle-ingredient-group'
      group : @props.groupName
    }
}

IngredientListItem = React.createClass {
  displayName : 'IngredientListItem'

  mixins : [
    FluxMixin IngredientStore, 'selectedIngredientTags'
  ]

  render : ->
    className = 'ingredient-list-item'
    if @state.selectedIngredientTags[@props.ingredient.tag]
      className += ' is-selected'

    <div className={className} onTouchTap={@_toggleIngredient}>
      <div className='name'>{@props.ingredient.display}</div>
      <i className='fa fa-check-circle'/>
    </div>

  _toggleIngredient : ->
    AppDispatcher.dispatch {
      type : 'toggle-ingredient'
      tag  : @props.ingredient.tag
    }
}

GroupedIngredientList = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'searchedGroupedIngredients', 'selectedIngredientTags'
    FluxMixin UiStore, 'openIngredientGroups'
  ]

  render : ->
    children = []
    for { name, ingredients } in @state.searchedGroupedIngredients
      selectedCount = _.filter(ingredients, (i) => @state.selectedIngredientTags[i.tag]?).length
      children.push <IngredientGroupHeader groupName={name} selectedCount={selectedCount} key={'header-' + name}/>
      if @state.openIngredientGroups[name]
        children.push <div className='ingredient-section' key={'section-' + name}>
          {_.map ingredients, (i) -> <IngredientListItem ingredient={i} key={i.tag}/>}
        </div>

    if children.length == 0
      children.push <div className='empty-search-results' key='empty'>Nothing matched your search.</div>

    <div className='ingredient-selection-list'>
      {children}
    </div>
}

IngredientSelectionView = React.createClass {
  render : ->
    <FixedHeaderFooter
      classNames='ingredient-list-view'
      header={<IngredientSelectionHeader/>}
    >
      <GroupedIngredientList/>
    </FixedHeaderFooter>
}

module.exports = IngredientSelectionView

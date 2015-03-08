# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require './FluxMixin'
AppDispatcher = require './AppDispatcher'

{ IngredientStore, UiStore } = require './stores'

SearchBar = require './SearchBar'

# TODO: Factor this out so we can share it between recipes and ingredients.
Header = React.createClass {
  getInitialState : ->
    return {
      searchBarVisible : false
    }

  render : ->
    <div className='ingredient-header'>
      <i className='fa fa-times-circle float-left' onClick={@_hideIngredients}/>
      <span className='header-title'>Ingredients</span>
      <i className='fa fa-search float-right' onClick={@_toggleSearch}/>
      <div className={'search-bar-wrapper ' + if @state.searchBarVisible then 'visible' else 'hidden'}>
        <SearchBar onChange={@_setSearchTerm} key='search-bar' ref='searchBar'/>
      </div>
    </div>

  _toggleSearch : ->
    searchBarVisible = not @state.searchBarVisible
    @setState { searchBarVisible }
    if searchBarVisible
      # This defer is a hack because we haven't rerendered but we can't focus hidden things.
      _.defer =>
        @refs.searchBar.clearAndFocus()
    else
      @refs.searchBar.clear()

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
  render : ->
    text = @props.groupName
    if @props.selectedCount > 0
      text += " (#{@props.selectedCount})"
    <div className='ingredient-group-header' onClick={@_toggleGroup}>
      <span>{text}</span>
    </div>

  _toggleGroup : ->
    AppDispatcher.dispatch {
      type  : 'toggle-ingredient-group'
      group : @props.groupName
    }
}

IngredientListItem = React.createClass {
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
    FluxMixin IngredientStore, 'groupedIngredients', 'selectedIngredientTags'
    FluxMixin UiStore, 'openIngredientGroups'
  ]

  render : ->
    children = []
    for { name, ingredients } in @state.groupedIngredients
      selectedCount = _.filter(ingredients, (i) => @state.selectedIngredientTags[i.tag]?).length
      children.push <IngredientGroupHeader groupName={name} selectedCount={selectedCount} key={'header-' + name}/>
      if @state.openIngredientGroups[name]
        children.push <div className='ingredient-section'>
          {_.map ingredients, (i) -> <IngredientListItem ingredient={i} key={i.tag}/>}
        </div>

    <div className='ingredient-selection-list'>
      {children}
    </div>
}

IngredientSelectionView = React.createClass {
  render : ->
    <div className='ingredient-list-view'>
      <div className='fixed-header-bar'>
        <Header/>
      </div>
      <div className='fixed-content-pane'>
        <GroupedIngredientList/>
      </div>
    </div>
}

module.exports = IngredientSelectionView

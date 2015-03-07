# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require './FluxMixin'
AppDispatcher = require './AppDispatcher'

{ IngredientStore } = require './stores'

SearchBar         = require './SearchBar'
StickyHeaderMixin = require './StickyHeaderMixin'

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

IngredientListItem = React.createClass {
  mixins : [
    FluxMixin IngredientStore, 'selectedIngredientTags'
  ]

  render : ->
    className = 'ingredient-list-item list-item'
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
    FluxMixin IngredientStore, 'groupedIngredients'
    StickyHeaderMixin
  ]

  render : ->
    data = _.chain @state.groupedIngredients
      .map ({ name, ingredients }) ->
        _.map ingredients, (i) -> [ name, i ]
      .flatten()
      .value()

    return @generateList {
      data        : data
      getTitle    : ([ name, ingredient ]) -> name
      createChild : ([ name, ingredient ]) -> <IngredientListItem ingredient={ingredient} key={ingredient.tag}/>
      classNames  : 'ingredient-list grouped'
    }
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

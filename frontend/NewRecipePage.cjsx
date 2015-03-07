# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin       = require './FluxMixin'
AppDispatcher   = require './AppDispatcher'
{ RecipeStore } = require './stores'

StickyHeaderMixin = require './StickyHeaderMixin'

SearchBar = React.createClass {
  getInitialState : ->
    return {
      value : ''
    }

  render : ->
    <div className='search-bar'>
      <input className='search-input' type='text' ref='input' onChange={@_onChange}/>
      <i className='fa fa-times-circle' onClick={@clearAndFocus}/>
    </div>

  clearAndFocus : ->
    @clear()
    @focus()

  clear : ->
    input = @refs.input.getDOMNode()
    input.value = ''
    @props.onChange ''

  focus : ->
    input = @refs.input.getDOMNode()
    input.focus()
    @props.onChange ''

  _onChange : (event) ->
    @props.onChange event.target.value
}

Header = React.createClass {
  getInitialState : ->
    return {
      searchBarVisible : false
    }

  render : ->
    <div className='recipe-header'>
      <i className='fa fa-list-ul left' onClick={-> console.log 'list click'}/>
      <span className='header-title'>Drinks</span>
      <i className='fa fa-search right' onClick={@_toggleSearch}/>
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
      type : 'search-recipes'
      searchTerm
    }
}

RecipeListItem = React.createClass {
  render : ->
    <div className='recipe-list-item list-item' onTouchTap={@_openRecipe}>
      <div className='name'>{@props.recipe.name}</div>
    </div>

  _openRecipe : ->
    AppDispatcher.dispatch {
      type   : 'open-recipe'
      recipe : @props.recipe
    }
}

AlphabeticalRecipeList = React.createClass {
  mixins : [
    FluxMixin RecipeStore, 'searchedAlphabeticalRecipes'
    StickyHeaderMixin
  ]

  render : ->
    return @generateList {
      data        : @state.searchedAlphabeticalRecipes
      getTitle    : (recipe) -> recipe.name[0].toUpperCase()
      createChild : (recipe) -> <RecipeListItem recipe={recipe} key={recipe.normalizedName}/>
      classNames  : 'recipe-list alphabetical'
    }
}


RecipePage = React.createClass {
  render : ->
    # There's no way rewrapping these elements in divs that give them the fixed classes is best practices.
    <div className='recipe-page'>
      <div className='fixed-header-bar'>
        <Header/>
      </div>
      <div className='fixed-content-pane'>
        <AlphabeticalRecipeList/>
      </div>
    </div>
}

module.exports = RecipePage

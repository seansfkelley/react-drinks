# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require './FluxMixin'
AppDispatcher = require './AppDispatcher'

{ RecipeStore, UiStore } = require './stores'

SearchBar         = require './SearchBar'
RecipeView        = require './RecipeView'
StickyHeaderMixin = require './StickyHeaderMixin'

# TODO: Factor this out so we can share it between recipes and ingredients.
Header = React.createClass {
  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  getInitialState : ->
    return {
      searchBarVisible : false
    }

  render : ->
    <div className='recipe-header'>
      <i className='fa fa-times-circle float-left' onClick={@_hideShoppingList}/>
      <span className='header-title'>Shopping List</span>
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

  _hideShoppingList : ->
    AppDispatcher.dispatch {
      type : 'hide-flyup'
    }

  # In the future, this should pop up a loader and then throttle the number of filters performed.
  _setSearchTerm : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-recipes'
      searchTerm
    }
}

IncompleteRecipeListItem = React.createClass {
  render : ->
    missingIngredients = _.map @props.recipe.missing, (m) ->
      return <div className='missing-ingredient' key={m.displayIngredient}>{m.displayMeasure ? ''} {m.displayIngredient}</div>
    <div className='incomplete-recipe-list-item list-item' onTouchTap={@_openRecipe}>
      <div className='name'>{@props.recipe.name}</div>
      {missingIngredients}
    </div>

  _openRecipe : ->
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <RecipeView recipe={@props.recipe}/>
    }
}

ShoppingList = React.createClass {
  mixins : [
    FluxMixin RecipeStore, 'searchedGroupedMixableRecipes'
    StickyHeaderMixin
  ]

  render : ->
    data = _.chain @state.searchedGroupedMixableRecipes
      .filter ({ missing }) -> missing > 0
      .map ({ name, recipes }) ->
        _.map recipes, (r) -> [ name, r ]
      .flatten()
      .value()

    return @generateList {
      data        : data
      getTitle    : ([ name, recipe ]) -> name
      createChild : ([ name, recipe ]) -> <IncompleteRecipeListItem recipe={recipe} key={recipe.normalizedName}/>
      classNames  : 'shopping-list grouped'
    }
}

ShoppingListView = React.createClass {
  render : ->
    <div className='shopping-list-view'>
      <div className='fixed-header-bar'>
        <Header/>
      </div>
      <div className='fixed-content-pane'>
        <ShoppingList/>
      </div>
    </div>
}

module.exports = ShoppingListView

# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require './FluxMixin'
AppDispatcher = require './AppDispatcher'

{ RecipeStore, UiStore } = require './stores'

SearchBar          = require './SearchBar'
SwipableRecipeView = require './SwipableRecipeView'
StickyHeaderMixin  = require './StickyHeaderMixin'

Header = React.createClass {
  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  getInitialState : ->
    return {
      searchBarVisible : false
    }

  render : ->
    if @state.useIngredients
      title = 'Mixable Drinks'
    else
      title = 'All Drinks'

    <div className='recipe-header'>
      <i className='fa fa-list-ul float-left' onTouchTap={-> console.log 'list click'}/>
      <span className='header-title'>{title}</span>
      <i className='fa fa-search float-right' onTouchTap={@_toggleSearch}/>
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
      <div className='name'>{@props.recipes[@props.index].name}</div>
    </div>

  _openRecipe : ->
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <SwipableRecipeView recipes={@props.recipes} index={@props.index}/>
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
      createChild : (recipe, i) => <RecipeListItem recipes={@state.searchedAlphabeticalRecipes} index={i} key={recipe.normalizedName}/>
      classNames  : 'recipe-list alphabetical'
    }
}

GroupedRecipeList = React.createClass {
  mixins : [
    FluxMixin RecipeStore, 'searchedGroupedMixableRecipes'
    StickyHeaderMixin
  ]

  render : ->
    data = _.chain @state.searchedGroupedMixableRecipes
      .map ({ name, recipes }) ->
        _.map recipes, (r) -> [ name, r ]
      .flatten()
      .value()

    # TODO: Fix this in a more elegant way I hope.
    recipes = _.pluck data, '1'

    return @generateList {
      data        : data
      getTitle    : ([ name, recipe ]) -> name
      createChild : ([ name, recipe ], i) -> <RecipeListItem recipes={recipes} index={i} key={recipe.normalizedName}/>
      classNames  : 'recipe-list grouped'
    }
}

RecipeListView = React.createClass {
  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  render : ->
    # There's no way rewrapping these elements in divs that give them the fixed classes is best practices.
    if @state.useIngredients
      list = <GroupedRecipeList/>
    else
      list = <AlphabeticalRecipeList/>

    <div className='recipe-list-view'>
      <div className='fixed-header-bar'>
        <Header/>
      </div>
      <div className='fixed-content-pane'>
        {list}
      </div>
    </div>
}

module.exports = RecipeListView

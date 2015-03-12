# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../FluxMixin'
AppDispatcher = require '../AppDispatcher'

{ RecipeStore, UiStore } = require '../stores'

FavoritesList      = require '../favorites/FavoritesList'
SwipableRecipeView = require '../recipes/SwipableRecipeView'
HeaderWithSearch   = require '../components/HeaderWithSearch'

HeaderedList = require '../components/HeaderedList'

RecipeListHeader = React.createClass {
  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  render : ->
    if @state.useIngredients
      title = 'Mixable Drinks'
    else
      title = 'All Drinks'

    <HeaderWithSearch
      leftIcon='fa-star'
      leftIconOnTouchTap={@_openFavorites}
      title={title}
      onSearch={@_setSearchTerm}
    />

  _openFavorites : ->
    AppDispatcher.dispatch {
      type      : 'show-pushover'
      component : <FavoritesList/>
    }

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
      <div className='name'>{@_getRecipe().name}</div>
    </div>

  _openRecipe : ->
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <SwipableRecipeView recipes={@props.recipes} index={@props.index}/>
    }

  _getRecipe : ->
    return RecipeListItem.getRecipeFor @

  statics :
    getRecipeFor : (element) ->
      return element.props.recipes[element.props.index]
}

_recipeListItemTitleExtractor = (child) ->
  return RecipeListItem.getRecipeFor(child).name[0].toUpperCase()

AlphabeticalRecipeList = React.createClass {
  mixins : [
    FluxMixin RecipeStore, 'searchedAlphabeticalRecipes'
  ]

  render : ->
    recipeNodes = _.map @state.searchedAlphabeticalRecipes, (r, i) =>
      <RecipeListItem recipes={@state.searchedAlphabeticalRecipes} index={i} key={r.normalizedName}/>

    <HeaderedList titleExtractor={_recipeListItemTitleExtractor}>
      {recipeNodes}
    </HeaderedList>
}

GroupedRecipeList = React.createClass {
  mixins : [
    FluxMixin RecipeStore, 'searchedGroupedMixableRecipes'
  ]

  render : ->
    # This whole munging of the group business is kinda gross.
    groupRecipePairs = _.chain @state.searchedGroupedMixableRecipes
      .map ({ name, recipes }) ->
        _.map recipes, (r) -> [ name, r ]
      .flatten()
      .value()

    orderedRecipes = _.pluck groupRecipePairs, '1'

    recipeNodes = _.map groupRecipePairs, ([ _, r ], i) =>
      <RecipeListItem recipes={orderedRecipes} index={i} key={r.normalizedName}/>

    <HeaderedList titleExtractor={_recipeListItemTitleExtractor}>
      {recipeNodes}
    </HeaderedList>
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
        <RecipeListHeader/>
      </div>
      <div className='fixed-content-pane'>
        {list}
      </div>
    </div>
}

module.exports = RecipeListView

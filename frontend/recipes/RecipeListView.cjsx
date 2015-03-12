# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../FluxMixin'
AppDispatcher = require '../AppDispatcher'

{ RecipeStore, UiStore } = require '../stores'

FavoritesList      = require '../favorites/FavoritesList'
SwipableRecipeView = require '../recipes/SwipableRecipeView'
StickyHeaderMixin  = require '../components/StickyHeaderMixin'
HeaderWithSearch   = require '../components/HeaderWithSearch'

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
        <RecipeListHeader/>
      </div>
      <div className='fixed-content-pane'>
        {list}
      </div>
    </div>
}

module.exports = RecipeListView

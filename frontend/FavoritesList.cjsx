# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin         = require './FluxMixin'
AppDispatcher     = require './AppDispatcher'
StickyHeaderMixin = require './StickyHeaderMixin'

{ UiStore, RecipeStore } = require './stores'

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

FavoritesList = React.createClass {
  mixins : [
    FluxMixin UiStore, 'favoritedRecipes'
    FluxMixin RecipeStore, 'alphabeticalRecipes'
    StickyHeaderMixin
  ]

  render : ->
    recipes = _.filter @state.alphabeticalRecipes, (r) => @state.favoritedRecipes[r.normalizedName]

    listNode = @generateList {
      data        : recipes
      getTitle    : (recipe) -> recipe.name[0].toUpperCase()
      createChild : (recipe, i) -> <RecipeListItem recipes={recipes} index={i} key={r.normalizedName}/>
    }

    <div className='favorites-list'>
      <div className='header'>Favorites</div>
      {listNode}
    </div>

  _close : ->
    AppDispatcher.dispatch {
      type : 'hide-pushover'
    }
}

module.exports = FavoritesList

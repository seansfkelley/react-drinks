# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../FluxMixin'
AppDispatcher = require '../AppDispatcher'

{ UiStore, RecipeStore } = require '../stores'

Header = require '../components/Header'

RecipeListItem = React.createClass {
  displayName : 'RecipeListItem'

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
  ]

  render : ->
    recipes = _.filter @state.alphabeticalRecipes, (r) => @state.favoritedRecipes[r.normalizedName]

    listNode = @generateList {
      data        : recipes
      getTitle    : (recipe) -> recipe.name[0].toUpperCase()
      createChild : (recipe, i) -> <RecipeListItem recipes={recipes} index={i} key={r.normalizedName}/>
    }

    <div className='favorites-list'>
      <Header
        leftIcon='fa-times-circle'
        leftIconOnTouchTap={@_closeFavorites}
        title='Favorites'
      />
      {listNode}
    </div>

  _closeFavorites : ->
    AppDispatcher.dispatch {
      type : 'hide-pushover'
    }
}

module.exports = FavoritesList

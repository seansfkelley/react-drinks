# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../mixins/FluxMixin'
AppDispatcher = require '../AppDispatcher'

{ UiStore, RecipeStore } = require '../stores'

FixedHeaderFooter  = require '../components/FixedHeaderFooter'
List               = require '../components/List'
Header             = require '../components/Header'
SwipableRecipeView = require '../recipes/SwipableRecipeView'

RecipeListItem = React.createClass {
  displayName : 'RecipeListItem'

  render : ->
    <List.Item className='recipe-list-item' onTouchTap={@_openRecipe}>
      <div className='name'>{@props.recipes[@props.index].name}</div>
    </List.Item>

  _openRecipe : ->
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <SwipableRecipeView recipes={@props.recipes} index={@props.index}/>
    }
}

FavoritesList = React.createClass {
  displayName : 'FavoritesList'

  mixins : [
    FluxMixin UiStore, 'favoritedRecipes'
    FluxMixin RecipeStore, 'alphabeticalRecipes'
  ]

  render : ->
    headerNode = <Header
      rightIcon='fa-chevron-left'
      rightIconOnTouchTap={@_closeFavorites}
      title='Favorites'/>

    recipes = _.filter @state.alphabeticalRecipes, (r) => @state.favoritedRecipes[r.normalizedName]

    recipeNodes = _.map recipes, (r, i) -> <RecipeListItem recipes={recipes} index={i} key={r.normalizedName}/>

    <FixedHeaderFooter header={headerNode}>
      <List.List className='favorites-list' emptyText='Add some favorites first!'>
        {recipeNodes}
      </List.List>
    </FixedHeaderFooter>

  _closeFavorites : ->
    AppDispatcher.dispatch {
      type : 'hide-pushover'
    }
}

module.exports = FavoritesList

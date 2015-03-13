# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../FluxMixin'
AppDispatcher = require '../AppDispatcher'

{ UiStore, RecipeStore } = require '../stores'

FixedHeaderFooter  = require '../components/FixedHeaderFooter'
Lists              = require '../components/Lists'
Header             = require '../components/Header'
SwipableRecipeView = require '../recipes/SwipableRecipeView'

RecipeListItem = React.createClass {
  displayName : 'RecipeListItem'

  render : ->
    <Lists.ListItem className='recipe-list-item' onTouchTap={@_openRecipe}>
      <div className='name'>{@props.recipes[@props.index].name}</div>
    </Lists.ListItem>

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
    headerNode = <Header
      leftIcon='fa-times-circle'
      leftIconOnTouchTap={@_closeFavorites}
      title='Favorites'/>

    recipes = _.filter @state.alphabeticalRecipes, (r) => @state.favoritedRecipes[r.normalizedName]

    recipeNodes = _.map recipes, (r, i) -> <RecipeListItem recipes={recipes} index={i} key={r.normalizedName}/>

    <FixedHeaderFooter header={headerNode}>
      <Lists.List>
        {recipeNodes}
      </Lists.List>
    </FixedHeaderFooter>

  _closeFavorites : ->
    AppDispatcher.dispatch {
      type : 'hide-pushover'
    }
}

module.exports = FavoritesList

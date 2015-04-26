_     = require 'lodash'
React = require 'react/addons'

FluxMixin = require '../mixins/FluxMixin'

FixedHeaderFooter  = require '../components/FixedHeaderFooter'
List               = require '../components/List'
TitleBar           = require '../components/TitleBar'

AppDispatcher            = require '../AppDispatcher'
{ UiStore, RecipeStore } = require '../stores'

SwipableRecipeView = require '../recipes/SwipableRecipeView'

RecipeListItem = React.createClass {
  displayName : 'RecipeListItem'

  propTypes :
    recipes : React.PropTypes.array.isRequired
    index   : React.PropTypes.number.isRequired

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

  propTypes : {}

  mixins : [
    FluxMixin UiStore, 'favoritedRecipes'
    FluxMixin RecipeStore, 'alphabeticalRecipes'
  ]

  render : ->
    headerNode = <TitleBar
      rightIcon='fa-chevron-left'
      rightIconOnTouchTap={@_closeFavorites}
      title='Favorites'/>

    recipes = _.filter @state.alphabeticalRecipes, (r) => @state.favoritedRecipes[r.recipeId]

    recipeNodes = _.map recipes, (r, i) -> <RecipeListItem recipes={recipes} index={i} key={r.recipeId}/>

    <FixedHeaderFooter header={headerNode} className='favorites-list-view'>
      <List className='favorites-list' emptyText='Add some favorites first!'>
        {recipeNodes}
      </List>
    </FixedHeaderFooter>

  _closeFavorites : ->
    AppDispatcher.dispatch {
      type : 'hide-pushover'
    }
}

module.exports = FavoritesList

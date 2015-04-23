React = require 'react/addons'

FluxMixin = require '../mixins/FluxMixin'

TitleBar = require '../components/TitleBar'

AppDispatcher = require '../AppDispatcher'
{ UiStore }   = require '../stores'

IngredientSelectionView = require './IngredientSelectionView'

SORT_ORDER_ICONS =
  alphabetical : 'fa-sort-alpha-asc'
  mixable      : 'fa-sort-numeric-asc'

IngredientsFooter = React.createClass {
  displayName : 'IngredientsFooter'

  propTypes : {}

  mixins : [
    FluxMixin UiStore, 'recipeSort'
  ]

  render : ->
    <TitleBar
      className='ingredients-footer'
      leftIcon={SORT_ORDER_ICONS[@state.recipeSort]}
      leftIconOnTouchTap={@_toggleRecipeSort}
      title='Ingredients'
      titleOnTouchTap={@_openIngredientPanel}
    />

  _toggleRecipeSort : ->
    AppDispatcher.dispatch {
      type : 'toggle-recipe-sort'
    }

  _openIngredientPanel : ->
    AppDispatcher.dispatch {
      type      : 'show-flyup'
      component : <IngredientSelectionView/>
    }
}

module.exports = IngredientsFooter

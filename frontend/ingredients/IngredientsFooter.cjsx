React = require 'react'

FluxMixin     = require '../mixins/FluxMixin'
AppDispatcher = require '../AppDispatcher'
{ UiStore }   = require '../stores'

TitleBar                = require '../components/TitleBar'
ShoppingList            = require '../shopping/ShoppingList'
IngredientSelectionView = require './IngredientSelectionView'

IngredientsFooter = React.createClass {
  displayName : 'IngredientsFooter'

  propTypes : {}

  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  render : ->
    if @state.useIngredients
      leftIcon = 'fa-check-square-o'
    else
      leftIcon = 'fa-square-o'

    <TitleBar
      className='ingredients-footer'
      leftIcon={leftIcon}
      leftIconOnTouchTap={@_toggleUseIngredients}
      title='Ingredients'
      titleOnTouchTap={@_openIngredientPanel}
      rightIcon='fa-shopping-cart'
      rightIconOnTouchTap={@_openShoppingList}
    />

  _toggleUseIngredients : ->
    AppDispatcher.dispatch {
      type : 'toggle-use-ingredients'
    }

  _openIngredientPanel : ->
    AppDispatcher.dispatch {
      type      : 'show-flyup'
      component : <IngredientSelectionView/>
    }

  _openShoppingList : ->
    AppDispatcher.dispatch {
      type      : 'show-flyup'
      component : <ShoppingList/>
    }
}

module.exports = IngredientsFooter

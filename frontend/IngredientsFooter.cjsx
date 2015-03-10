React = require 'react'

FluxMixin     = require './FluxMixin'
AppDispatcher = require './AppDispatcher'
{ UiStore }   = require './stores'

ShoppingList            = require './ShoppingList'
IngredientSelectionView = require './IngredientSelectionView'

IngredientsFooter = React.createClass {
  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  render : ->
    if @state.useIngredients
      iconClass = 'fa-check-square-o'
    else
      iconClass = 'fa-square-o'
    <div className='ingredients-footer'>
      <i className={'fa float-left ' + iconClass} onTouchTap={@_toggleUseIngredients}/>
      <span className='footer-title' onTouchTap={@_openIngredientPanel}>Ingredients</span>
      <i className='fa fa-shopping-cart float-right' onTouchTap={@_openShoppingList}/>
    </div>

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

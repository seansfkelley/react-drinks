React = require 'react'

FluxMixin     = require '../mixins/FluxMixin'
AppDispatcher = require '../AppDispatcher'
{ UiStore }   = require '../stores'

TitleBar                = require '../components/TitleBar'
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
}

module.exports = IngredientsFooter

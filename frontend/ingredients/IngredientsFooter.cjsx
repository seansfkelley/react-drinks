React = require 'react/addons'

TitleBar = require '../components/TitleBar'

AppDispatcher = require '../AppDispatcher'

IngredientSelectionView = require './IngredientSelectionView'

IngredientsFooter = React.createClass {
  displayName : 'IngredientsFooter'

  propTypes : {}

  render : ->
    <TitleBar className='ingredients-footer' onTouchTap={@_openIngredientPanel}>
      Ingredients
    </TitleBar>

  _openIngredientPanel : ->
    AppDispatcher.dispatch {
      type      : 'show-flyup'
      component : <IngredientSelectionView/>
    }
}

module.exports = IngredientsFooter

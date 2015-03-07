React = require 'react'

FluxMixin     = require './FluxMixin'
AppDispatcher = require './AppDispatcher'
{ UiStore }   = require './stores'

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
      <i className={'fa float-left ' + iconClass} onClick={@_toggleUseIngredients}/>
      <span className='footer-title'>Ingredients</span>
      <i className='fa fa-shopping-cart float-right'/>
    </div>

  _toggleUseIngredients : ->
    AppDispatcher.dispatch {
      type : 'toggle-use-ingredients'
    }
}

module.exports = IngredientsFooter

React = require 'react'

IngredientsFooter = React.createClass {
  render : ->
    <div className='ingredients-footer'>
      <i className='fa fa-square-o float-left'/>
      <span className='footer-title'>Ingredients</span>
      <i className='fa fa-shopping-cart float-right'/>
    </div>
}

module.exports = IngredientsFooter

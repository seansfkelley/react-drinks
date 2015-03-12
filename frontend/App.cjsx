# @cjsx React.DOM

React = require 'react'

RecipeListView    = require './recipes/RecipeListView'
IngredientsFooter = require './ingredients/IngredientsFooter'

App = React.createClass {
  render : ->
    <div className='drinks-app'>
      <div className='fixed-content-pane'>
        <RecipeListView/>
      </div>
      <div className='fixed-footer-bar'>
        <IngredientsFooter/>
      </div>
    </div>
}

module.exports = App

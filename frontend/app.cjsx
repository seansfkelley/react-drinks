# @cjsx React.DOM

React = require 'react'

RecipeListView    = require './RecipeListView'
IngredientsFooter = require './IngredientsFooter'

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

require('./overlayViews').attachOverlayViews()

React.render <App/>, document.querySelector('#app-root')

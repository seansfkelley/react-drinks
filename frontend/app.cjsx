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

_oldOnTouchStart = document.ontouchstart
document.ontouchstart = (e) ->
  # This autoblur attribute is kind of a hack, cause we don't want clearing the search input
  # to unfocus it (cause you touched something else) and then immediately refocus it.
  if e.target.nodeName != 'INPUT' and e.target.dataset.autoblur != 'false'
    document.activeElement.blur()
  return _oldOnTouchStart?(arguments...)

require('./overlayViews').attachOverlayViews()

React.render <App/>, document.querySelector('#app-root')

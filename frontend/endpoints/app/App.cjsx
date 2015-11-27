React = require 'react'

RecipeListView = require '../../recipes/RecipeListView'

App = React.createClass {
  displayName : 'App'

  propTypes : {}

  render : ->
    <div className='app-event-wrapper' onTouchStart={@_deselectActiveElement}>
      <RecipeListView/>
      <div className='overlay-background' onTouchStart={@_closeCurrentOverlay}/>
    </div>

  _deselectActiveElement : ->
    document.activeElement?.blur()

  _closeCurrentOverlay : ->
    console.log 'clicked outside!'
}

module.exports = App

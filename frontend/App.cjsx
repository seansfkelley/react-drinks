React = require 'react/addons'

RecipeListView = require './recipes/RecipeListView'

App = React.createClass {
  displayName : 'App'

  propTypes : {}

  render : ->
    <div className='app-event-wrapper' onTouchStart={@_deselectActiveElement}>
      <RecipeListView/>
    </div>

  _deselectActiveElement : ->
    document.activeElement?.blur()
}

module.exports = App

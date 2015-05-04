React = require 'react/addons'

FixedHeaderFooter = require './components/FixedHeaderFooter'
RecipeListView    = require './recipes/RecipeListView'
IngredientsFooter = require './ingredients/IngredientsFooter'

App = React.createClass {
  displayName : 'App'

  propTypes : {}

  render : ->
    <div className='app-event-wrapper' onTouchStart={@_deselectActiveElement}>
      <FixedHeaderFooter footer={<IngredientsFooter/>}>
        <RecipeListView/>
      </FixedHeaderFooter>
    </div>

  _deselectActiveElement : ->
    document.activeElement?.blur()
}

module.exports = App

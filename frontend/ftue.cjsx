_     = require 'lodash'
React = require 'react/addons'

FluxMixin = require './mixins/FluxMixin'

List = require './components/List'

AppDispatcher       = require './AppDispatcher'
{ IngredientStore } = require './stores'

FtueView = React.createClass {
  displayName : 'FtueView'

  mixins : [ FluxMixin IngredientStore, 'alphabeticalIngredients' ]

  propTypes : {}

  render : ->
    <div className='ftue-view'>
      <List>
      {for ingredient in @state.alphabeticalIngredients
        <List.Item key={ingredient.tag ? ingredient.display}>{ingredient.display}</List.Item>}
      </List>
    </div>
}

LOCALSTORAGE_KEY = 'drinks-app-ftue'

module.exports = {
  renderIfAppropriate : ->
    if not localStorage[LOCALSTORAGE_KEY]
      AppDispatcher.dispatch {
        type      : 'show-modal'
        component : <FtueView/>
      }
}

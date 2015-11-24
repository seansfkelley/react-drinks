_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

store = require '../store'

definitions = require '../../shared/definitions'

ReduxMixin = require '../mixins/ReduxMixin'

RecipeListSelector = React.createClass {
  displayName : 'RecipeListSelector'

  propTypes :
    onClose : React.PropTypes.func

  mixins : [
    ReduxMixin {
      ui : 'selectedRecipeList'
    }
    PureRenderMixin
  ]

  render : ->
    options = _.map definitions.RECIPE_LIST_TYPES, (type) =>
      <div
        key={type}
        className={classnames 'option', { 'is-selected' : type == @state.selectedRecipeList }}
        onTouchTap={@_onOptionSelect.bind(null, type)}
      >
        <span className='label'>{definitions.RECIPE_LIST_NAMES[type]}</span>
      </div>

    <div className='recipe-list-selector'>
      {options}
    </div>

  _onOptionSelect : (listType) ->
    store.dispatch {
      type : 'set-selected-recipe-list'
      listType
    }
    @props.onClose()
}

module.exports = RecipeListSelector

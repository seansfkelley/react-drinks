_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

store = require '../store'

ReduxMixin = require '../mixins/ReduxMixin'

definitions = require '../../shared/definitions'

List = require '../components/List'

EditableRecipePage = require './EditableRecipePage'

EditableBaseLiquorPage = React.createClass {
  displayName : 'EditableBaseLiquorPage'

  mixins : [
    ReduxMixin {
      editableRecipe : 'base'
    }
    PureRenderMixin
  ]

  propTypes :
    onClose       : React.PropTypes.func.isRequired
    onNext        : React.PropTypes.func
    onPrevious    : React.PropTypes.func
    previousTitle : React.PropTypes.string

  render : ->
    React.createElement(EditableRecipePage, { \
      "className": 'base-tag-page',  \
      "onClose": (@props.onClose),  \
      "onPrevious": (@props.onPrevious),  \
      "previousTitle": (@props.previousTitle)
    },
      React.createElement("div", {"className": 'fixed-content-pane'},
        React.createElement("div", {"className": 'page-title'}, "Base ingredient(s)"),
        React.createElement(List, null,
          (for tag in definitions.BASE_LIQUORS
            React.createElement(List.Item, { \
              "className": (classnames 'base-liquor-option', { 'is-selected' : tag in @state.base }),  \
              "onTouchTap": (@_tagToggler tag),  \
              "key": "tag-#{tag}"
            },
              (definitions.BASE_TITLES_BY_TAG[tag]),
              React.createElement("i", {"className": 'fa fa-check-circle'})
            ))
        ),
        React.createElement("div", {"className": (classnames 'next-button', { 'disabled' : not @_isEnabled() }), "onTouchTap": (@_nextIfEnabled)},
          React.createElement("span", {"className": 'next-text'}, "Next"),
          React.createElement("i", {"className": 'fa fa-arrow-right'})
        )
      )
    )

  _isEnabled : ->
    return @state.base.length > 0

  _nextIfEnabled : ->
    if @_isEnabled()
      @props.onNext()

  _tagToggler : (tag) ->
    return =>
      store.dispatch {
        type : 'toggle-base-liquor-tag'
        tag
      }
}

module.exports = EditableBaseLiquorPage

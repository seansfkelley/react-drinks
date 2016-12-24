_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

store = require '../store'

ReduxMixin = require '../mixins/ReduxMixin'

EditableRecipePage = require './EditableRecipePage'

EditableNamePage = React.createClass {
  displayName : 'EditableNamePage'

  mixins : [
    ReduxMixin {
      editableRecipe : 'name'
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
      "className": 'name-page',  \
      "onClose": (@props.onClose),  \
      "onPrevious": (@props.onPrevious),  \
      "previousTitle": (@props.previousTitle)
    },
      React.createElement("div", {"className": 'fixed-content-pane'},
        React.createElement("div", {"className": 'page-title'}, "Add a Recipe"),
        React.createElement("input", { \
          "type": 'text',  \
          "placeholder": 'Name...',  \
          "autoCorrect": 'off',  \
          "autoCapitalize": 'on',  \
          "autoComplete": 'off',  \
          "spellCheck": 'false',  \
          "ref": 'input',  \
          "value": (@state.name),  \
          "onChange": (@_onChange),  \
          "onTouchTap": (@_focus)
        }),
        React.createElement("div", {"className": (classnames 'next-button', { 'disabled' : not @_isEnabled() }), "onTouchTap": (@_nextIfEnabled)},
          React.createElement("span", {"className": 'next-text'}, "Next"),
          React.createElement("i", {"className": 'fa fa-arrow-right'})
        )
      )
    )

  _focus : ->
    @refs.input.focus()

  # mixin-ify this kind of stuff probably
  _isEnabled : ->
    return !!@state.name

  _nextIfEnabled : ->
    if @_isEnabled()
      store.dispatch {
        type : 'set-name'
        name : @state.name.trim()
      }
      @props.onNext()

  _onChange : (e) ->
    store.dispatch {
      type : 'set-name'
      name : e.target.value
    }
}

module.exports = EditableNamePage

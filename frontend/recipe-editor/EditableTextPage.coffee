React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

store = require '../store'

ReduxMixin = require '../mixins/ReduxMixin'

EditableRecipePage = require './EditableRecipePage'

EditableTextPage = React.createClass {
  displayName : 'EditableTextPage'

  mixins : [
    ReduxMixin {
      editableRecipe : [ 'instructions', 'notes' ]
    }
  ]

  propTypes :
    onClose       : React.PropTypes.func.isRequired
    onNext        : React.PropTypes.func
    onPrevious    : React.PropTypes.func
    previousTitle : React.PropTypes.string

  render : ->
    React.createElement(EditableRecipePage, { \
      "className": 'text-page',  \
      "onClose": (@props.onClose),  \
      "onPrevious": (@props.onPrevious),  \
      "previousTitle": (@props.previousTitle)
    },
      React.createElement("div", {"className": 'fixed-content-pane'},
        React.createElement("textarea", { \
          "className": 'editable-text-area',  \
          "placeholder": 'Instructions...',  \
          "onChange": (@_setInstructions),  \
          "value": (@state.instructions),  \
          "ref": 'instructions'
        }),
        React.createElement("textarea", { \
          "className": 'editable-text-area',  \
          "placeholder": 'Notes (optional)...',  \
          "onChange": (@_setNotes),  \
          "value": (@state.notes),  \
          "ref": 'notes'
        }),
        React.createElement("div", {"className": (classnames 'next-button', { 'disabled' : not @_isEnabled() }), "onTouchTap": (@_nextIfEnabled)},
          React.createElement("span", {"className": 'next-text'}, "Next"),
          React.createElement("i", {"className": 'fa fa-arrow-right'})
        )
      )
    )

  _isEnabled : ->
    return @state.instructions.length

  _nextIfEnabled : ->
    if @_isEnabled()
      @props.onNext()

  _setInstructions : (e) ->
    store.dispatch {
      type         : 'set-instructions'
      instructions : e.target.value
    }

  _setNotes : (e) ->
    store.dispatch {
      type  : 'set-notes'
      notes : e.target.value
    }
}

module.exports = EditableTextPage

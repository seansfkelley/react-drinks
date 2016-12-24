React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'
classnames      = require 'classnames'

ReduxMixin = require '../mixins/ReduxMixin'

ErrorMessageOverlay = React.createClass {
  displayName : 'ErrorMessageOverlay'

  propTypes : {}

  mixins : [
    ReduxMixin {
      ui : 'errorMessage'
    }
    PureRenderMixin
  ]

  render : ->
    if not @state.errorMessage
      content = null
    else
      content = React.createElement("div", {"className": 'error-message'},
        React.createElement("i", {"className": 'fa fa-exclamation-circle'}),
        React.createElement("div", {"className": 'message-text'}, (@state.errorMessage))
      )

    React.createElement("div", {"className": (classnames 'error-message-overlay', { 'visible' : @state.errorMessage } )},
      (content)
    )
}

module.exports = ErrorMessageOverlay

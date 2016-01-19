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
      content = <div className='error-message'>
        <i className='fa fa-exclamation-circle'/>
        <div className='message-text'>{@state.errorMessage}</div>
      </div>

    <div className={classnames 'error-message-overlay', { 'visible' : @state.errorMessage } }>
      {content}
    </div>
}

module.exports = ErrorMessageOverlay

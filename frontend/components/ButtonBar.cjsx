_               = require 'lodash'
React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'
classnames      = require 'classnames'

ButtonBar = React.createClass {
  displayName : 'ButtonBar'

  propTypes :
    buttons : React.PropTypes.arrayOf(React.PropTypes.shape({
      icon       : React.PropTypes.string
      text       : React.PropTypes.string
      onTouchTap : React.PropTypes.func
      enabled    : React.PropTypes.bool
    })).isRequired
    className : React.PropTypes.string

  mixins : [ PureRenderMixin ]

  render : ->
    buttons = _.map @props.buttons, (button, i) =>
      <div className={classnames 'button', { enabled : button.enabled ? true }} onTouchTap={@_makeOnTouchTap i} key={i}>
        <i className={classnames 'fa', button.icon}/>
        <div className='text'>{button.text}</div>
      </div>

    <div className='button-bar'>
      {buttons}
    </div>

  _makeOnTouchTap : _.memoize (i) ->
    return (->
      enabled = @props.buttons[i].enabled
      if enabled ? true
        @props.buttons[i].onTouchTap()
    ).bind(@)
}

module.exports = ButtonBar

# @cjsx React.DOM

_          = require 'lodash'
React      = require 'react'
classnames = require 'classnames'

ButtonBar = React.createClass {
  displayName : 'ButtonBar'

  propTypes : {}

  render : ->
    <div className={classnames 'button-bar', @props.className}>
      {@props.children}
    </div>
}

ButtonBar.Button = React.createClass {
  displayName : 'ButtonBar.Button'

  propTypes :
    icon     : React.PropTypes.string
    label    : React.PropTypes.string
    disabled : React.PropTypes.bool

  render : ->
    renderableProps = _.omit @props, 'icon', 'label', 'disabled'
    <div {...renderableProps} className={classnames 'button', @props.className, { 'disabled' : @props.disabled }}>
      {if @props.icon then <i className={'fa ' + @props.icon}/>}
      {if @props.label then <span>{@props.label}</span>}
    </div>
}

module.exports = ButtonBar

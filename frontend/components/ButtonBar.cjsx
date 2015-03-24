# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

ClassNameMixin = require '../mixins/ClassNameMixin'

ButtonBar = React.createClass {
  displayName : 'ButtonBar'

  propTypes : {}

  mixins : [
    ClassNameMixin
  ]

  render : ->
    <div className={@getClassName 'button-bar'}>
      {@props.children}
    </div>
}

ButtonBar.Button = React.createClass {
  displayName : 'ButtonBar.Button'

  propTypes :
    icon  : React.PropTypes.string
    label : React.PropTypes.string

  mixins : [
    ClassNameMixin
  ]

  render : ->
    renderableProps = _.omit @props, 'icon', 'label'
    <div {...renderableProps} className={@getClassName 'button'}>
      {if @props.icon then <i className={'fa ' + @props.icon}/>}
      {if @props.label then <span>{@props.label}</span>}
    </div>
}

module.exports = ButtonBar

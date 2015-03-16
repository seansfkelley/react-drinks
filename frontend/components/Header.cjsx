# @cjsx React.DOM

React = require 'react'

ClassNameMixin = require '../mixins/ClassNameMixin'

Header = React.createClass {
  displayName : 'Header'

  propTypes :
    leftIcon            : React.PropTypes.string
    title               : React.PropTypes.string.isRequired
    rightIcon           : React.PropTypes.string
    leftIconOnTouchTap  : React.PropTypes.func
    titleOnTouchTap     : React.PropTypes.func
    rightIconOnTouchTap : React.PropTypes.func


  mixins : [
    ClassNameMixin
  ]

  render : ->
    title = <span className='header-title' onTouchTap={@props.titleOnTouchTap}>{@props.title}</span>

    if @props.leftIcon?
      leftIcon = <i className={'fa float-left ' + @props.leftIcon} onTouchTap={@props.leftIconOnTouchTap} onTouchStart={@_stopTouchStart}/>

    if @props.rightIcon?
      rightIcon = <i className={'fa float-right ' + @props.rightIcon} onTouchTap={@props.rightIconOnTouchTap} onTouchStart={@_stopTouchStart}/>

    if @props.leftIcon? or @props.rightIcon?
      leftIcon  ?= <i className='fa float-left'/>
      rightIcon ?= <i className='fa float-right'/>

    <div className={@getClassName 'header'}>
      {leftIcon}
      {title}
      {rightIcon}
      {@props.children}
    </div>

  _stopTouchStart : (e) ->
    # This is hacky, but both of these are independently necessary.
    # 1. Stop propagation so that the App-level handler doesn't deselect the input on clear.
    e.stopPropagation()
    # 2. Prevent default so that iOS doesn't reassign the active element and deselect the input.
    e.preventDefault()
}

module.exports = Header

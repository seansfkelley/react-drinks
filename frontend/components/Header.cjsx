# @cjsx React.DOM

React = require 'react'

Header = React.createClass {
  displayName : 'Header'

  propTypes :
    classNames          : React.PropTypes.string
    leftIcon            : React.PropTypes.string
    title               : React.PropTypes.string.isRequired
    rightIcon           : React.PropTypes.string
    leftIconOnTouchTap  : React.PropTypes.func
    titleOnTouchTap     : React.PropTypes.func
    rightIconOnTouchTap : React.PropTypes.func

  getDefaultProps : -> {
    classNames : ''
  }

  render : ->
    title = <span className='header-title' onTouchTap={@props.titleOnTouchTap}>{@props.title}</span>

    if @props.leftIcon?
      leftIcon = <i className={'fa float-left ' + @props.leftIcon} onTouchTap={@props.leftIconOnTouchTap}/>
    else
      leftIcon = <i className='fa float-left'/>

    if @props.rightIcon?
      rightIcon = <i className={'fa float-right ' + @props.rightIcon} onTouchTap={@props.rightIconOnTouchTap}/>
    else
      rightIcon = <i className='fa float-right'/>

    <div className={'header ' + @props.classNames}>
      {leftIcon}
      {title}
      {rightIcon}
      {@props.children}
    </div>
}

module.exports = Header

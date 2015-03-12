# @cjsx React.DOM

React = require 'react'

Header = React.createClass {
  propTypes :
    classNames          : React.PropTypes.string
    leftIcon            : React.PropTypes.string
    title               : React.PropTypes.string.isRequired
    rightIcon           : React.PropTypes.string
    leftIconOnTouchTap  : React.PropTypes.func
    titleOnTouchTap     : React.PropTypes.func
    rightIconOnTouchTap : React.PropTypes.func

  render : ->
    title = <span className='header-title' onTouchTap={@props.titleOnTouchTap}>{@props.title}</span>
    if @props.leftIcon?
      leftIcon = <i className={'fa float-left ' + @props.leftIcon} onTouchTap={@props.leftIconOnTouchTap}/>
    if @props
      rightIcon = <i className={'fa float-right ' + @props.rightIcon} onTouchTap={@props.rightIconOnTouchTap}/>
    classNames = 'header '
    if @props.classNames?
      classNames += @props.classNames

    <div className={classNames}>
      {leftIcon}
      {title}
      {rightIcon}
      {@props.children}
    </div>
}

module.exports = Header

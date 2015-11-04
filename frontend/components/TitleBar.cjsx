React      = require 'react'
classnames = require 'classnames'

TitleBar = React.createClass {
  displayName : 'TitleBar'

  propTypes :
    leftIcon            : React.PropTypes.string
    children            : React.PropTypes.oneOfType([
      React.PropTypes.element
      React.PropTypes.string
    ])
    rightIcon           : React.PropTypes.string
    leftIconOnTouchTap  : React.PropTypes.func
    onTouchTap          : React.PropTypes.func
    rightIconOnTouchTap : React.PropTypes.func

  render : ->
    if @props.leftIcon?
      if @props.leftIcon[0...2] == 'fa'
        leftIcon = <i
          className={'fa float-left ' + @props.leftIcon}
          onTouchTap={@props.leftIconOnTouchTap}
        />
      else
        leftIcon = <img
          src={@props.leftIcon}
          onTouchTap={@props.leftIconOnTouchTap}
        />

    if @props.rightIcon?
      if @props.rightIcon[0...2] == 'fa'
        rightIcon = <i
          className={'fa float-right ' + @props.rightIcon}
          onTouchTap={@props.rightIconOnTouchTap}
        />
      else
        rightIcon = <img
          src={@props.rightIcon}
          onTouchTap={@props.rightIconOnTouchTap}
        />

    showingIcons = @props.leftIcon? or @props.rightIcon?

    if showingIcons
      leftIcon  ?= <span className='spacer float-left'>&nbsp;</span>
      rightIcon ?= <span className='spacer float-right'>&nbsp;</span>

    <div className={classnames 'title-bar', @props.className} onTouchTap={@props.onTouchTap}>
      {leftIcon}
      {if React.Children.count(@props.children) > 0
        <div className={classnames 'title', { 'showing-icons' : showingIcons }}>
          {@props.children}
        </div>}
      {rightIcon}
    </div>
}

module.exports = TitleBar

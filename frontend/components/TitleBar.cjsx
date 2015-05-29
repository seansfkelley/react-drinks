React      = require 'react/addons'
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
      leftIcon = <i
        className={'fa float-left ' + @props.leftIcon}
        onTouchTap={@props.leftIconOnTouchTap}
        onTouchStart={@_stopTouchStart}
      />

    if @props.rightIcon?
      rightIcon = <i
        className={'fa float-right ' + @props.rightIcon}
        onTouchTap={@props.rightIconOnTouchTap}
        onTouchStart={@_stopTouchStart}
      />

    showingIcons = @props.leftIcon? or @props.rightIcon?

    if showingIcons
      # <i> doesn't work with the styling for some reason.
      leftIcon  ?= <span className='fa float-left'/>
      rightIcon ?= <span className='fa float-right'/>

    <div className={classnames 'title-bar', @props.className} onTouchTap={@props.onTouchTap}>
      {leftIcon}
      {if React.Children.count(@props.children) > 0
        <div className={classnames 'title', { 'showing-icons' : showingIcons }}>
          {@props.children}
        </div>}
      {rightIcon}
    </div>

  _stopTouchStart : (e) ->
    # This is hacky, but both of these are independently necessary.
    # 1. Stop propagation so that the App-level handler doesn't deselect the input on clear.
    # e.stopPropagation()
    # 2. Prevent default so that iOS doesn't reassign the active element and deselect the input.
    e.preventDefault()
}

module.exports = TitleBar

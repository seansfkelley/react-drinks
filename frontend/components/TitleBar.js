React      = require 'react'
classnames = require 'classnames'

TitleBar = React.createClass {
  displayName : 'TitleBar'

  propTypes :
    leftIcon            : React.PropTypes.string
    children            : React.PropTypes.node
    rightIcon           : React.PropTypes.string
    leftIconOnTouchTap  : React.PropTypes.func
    onTouchTap          : React.PropTypes.func
    rightIconOnTouchTap : React.PropTypes.func

  render : ->
    if @props.leftIcon?
      if @props.leftIcon[0...2] == 'fa'
        leftIcon = React.createElement("i", { \
          "className": ('fa float-left ' + @props.leftIcon),  \
          "onTouchTap": (@props.leftIconOnTouchTap)
        })
      else
        leftIcon = React.createElement("img", { \
          "src": (@props.leftIcon),  \
          "onTouchTap": (@props.leftIconOnTouchTap)
        })

    if @props.rightIcon?
      if @props.rightIcon[0...2] == 'fa'
        rightIcon = React.createElement("i", { \
          "className": ('fa float-right ' + @props.rightIcon),  \
          "onTouchTap": (@props.rightIconOnTouchTap)
        })
      else
        rightIcon = React.createElement("img", { \
          "src": (@props.rightIcon),  \
          "onTouchTap": (@props.rightIconOnTouchTap)
        })

    showingIcons = @props.leftIcon? or @props.rightIcon?

    if showingIcons
      leftIcon  ?= React.createElement("span", {"className": 'spacer float-left'}, " ")
      rightIcon ?= React.createElement("span", {"className": 'spacer float-right'}, " ")

    React.createElement("div", {"className": (classnames 'title-bar', @props.className)},
      (leftIcon),
      (if React.Children.count(@props.children) > 0 then React.createElement("div", {"className": (classnames 'title', { 'showing-icons' : showingIcons }), "onTouchTap": (@props.onTouchTap)},
          (@props.children)
        )),
      (rightIcon)
    )
}

module.exports = TitleBar

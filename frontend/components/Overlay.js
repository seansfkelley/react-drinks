_          = require 'lodash'
React      = require 'react'
classnames = require 'classnames'

Overlay = React.createClass {
  displayName : 'Overlay'

  propTypes :
    isVisible : React.PropTypes.bool.isRequired
    type      : React.PropTypes.oneOf([ 'modal', 'flyup', 'pushover' ]).isRequired
    children  : React.PropTypes.element

  render : ->
    React.createElement("div", {"className": (classnames 'overlay', { 'visible' : @props.isVisible }, @props.type)},
      (@props.children)
    )
}

module.exports = Overlay
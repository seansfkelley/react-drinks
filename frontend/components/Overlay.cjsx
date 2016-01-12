_               = require 'lodash'
React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'
classnames      = require 'classnames'

Overlay = React.createClass {
  displayName : 'Overlay'

  propTypes :
    isVisible : React.PropTypes.bool.isRequired
    type      : React.PropTypes.oneOf([ 'modal', 'flyup', 'pushover' ]).isRequired
    children  : React.PropTypes.element

  mixins : [ PureRenderMixin ]

  render : ->
    <div className={classnames 'overlay', { 'visible' : @props.isVisible }, @props.type}>
      {@props.children}
    </div>
}

module.exports = Overlay

# @cjsx React.DOM

_      = require 'lodash'
React  = require 'react'

IconButton = React.createClass {
  displayName : 'IconButton'

  propTypes :
    iconClass : React.PropTypes.string

  render : ->
    renderableProps = _.omit @props, 'iconClass'
    <div  {...renderableProps} className={classnames 'icon-button', @props.className}>
      <i className={'fa ' + @props.iconClass}/>
    </div>
}

module.exports = IconButton

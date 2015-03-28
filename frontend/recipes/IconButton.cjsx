# @cjsx React.DOM

_      = require 'lodash'
React  = require 'react'

ClassNameMixin = require '../mixins/ClassNameMixin'

IconButton = React.createClass {
  displayName : 'IconButton'

  propTypes :
    iconClass : React.PropTypes.string

  mixins : [
    ClassNameMixin
  ]

  render : ->
    renderableProps = _.omit @props, 'iconClass'
    <div  {...renderableProps} className={@getClassName 'icon-button'}>
      <i className={'fa ' + @props.iconClass}/>
    </div>
}

module.exports = IconButton

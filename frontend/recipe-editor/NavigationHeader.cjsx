React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'
classnames      = require 'classnames'

NavigationHeader = React.createClass {
  displayName : 'NavigationHeader'

  propTypes :
    onClose       : React.PropTypes.func.isRequired
    previousTitle : React.PropTypes.string
    onPrevious    : React.PropTypes.func
    className     : React.PropTypes.string

  mixins : [
    PureRenderMixin
  ]

  render : ->
    <div className={classnames 'navigation-header', @props.className}>
      {if @props.previousTitle and @props.onPrevious
        <div className='back-button float-left' onTouchTap={@props.onPrevious}>
          <i className='fa fa-chevron-left'/>
          <span className='back-button-label'>{@props.previousTitle}</span>
        </div>}
      <i className='fa fa-times float-right' onTouchTap={@props.onClose}/>
    </div>
}

module.exports = NavigationHeader

# @cjsx React.DOM

React = require 'react'

FixedHeaderFooter = React.createClass {
  displayName : 'FixedHeaderFooter'

  propTypes :
    classNames : React.PropTypes.string
    header     : React.PropTypes.element
    footer     : React.PropTypes.element

  getDefaultProps : -> {
    classNames : ''
  }

  render : ->
    <div className={'fixed-header-footer ' + @props.classNames}>
      {@_wrapIfDefined @props.header, 'fixed-header'}
      <div className='fixed-content-pane'>
        {@props.children}
      </div>
      {@_wrapIfDefined @props.footer, 'fixed-footer'}
    </div>

  _wrapIfDefined : (element, className) ->
    if element?
      return <div className={className}>{element}</div>
}

module.exports = FixedHeaderFooter

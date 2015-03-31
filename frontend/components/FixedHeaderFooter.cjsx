# @cjsx React.DOM

React      = require 'react'
classnames = require 'classnames'

FixedHeaderFooter = React.createClass {
  displayName : 'FixedHeaderFooter'

  propTypes :
    header : React.PropTypes.element
    footer : React.PropTypes.element

  render : ->
    <div className={classnames 'fixed-header-footer', @props.className}>
      {@_wrapIfDefined @props.header, 'fixed-header'}
      <div className='fixed-content-pane' ref='content'>
        {@props.children}
      </div>
      {@_wrapIfDefined @props.footer, 'fixed-footer'}
    </div>

  scrollTo : (offset) ->
    @refs.content.getDOMNode().scrollTop = offset

  _wrapIfDefined : (element, className) ->
    if element?
      return <div className={className}>{element}</div>
}

module.exports = FixedHeaderFooter

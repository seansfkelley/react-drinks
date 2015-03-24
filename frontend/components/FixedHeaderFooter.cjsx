# @cjsx React.DOM

React = require 'react'

ClassNameMixin = require '../mixins/ClassNameMixin'

FixedHeaderFooter = React.createClass {
  displayName : 'FixedHeaderFooter'

  propTypes :
    header : React.PropTypes.element
    footer : React.PropTypes.element

  mixins : [
    ClassNameMixin
  ]

  render : ->
    <div className={@getClassName 'fixed-header-footer'}>
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

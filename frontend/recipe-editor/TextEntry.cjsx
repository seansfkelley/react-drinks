React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'
classnames      = require 'classnames'

TextEntry = React.createClass {
  displayName : 'TextEntry'

  propTypes :
    value       : React.PropTypes.string.isRequired
    onChange    : React.PropTypes.func.isRequired
    instruction : React.PropTypes.string.isRequired
    placeholder : React.PropTypes.string.isRequired
    className   : React.PropTypes.string

  mixins : [ PureRenderMixin ]

  render : ->
    <div className={classnames 'text-entry', @props.className}>
      <div className='instruction'>{@props.instruction}</div>
      <textarea
        className='editable-text-area'
        placeholder={@props.placeholder}
        onChange={@_onChange}
        onTouchTap={@_focus}
        value={@props.value}
        ref='text'
      />
    </div>

  _onChange : (e) ->
    @props.onChange e.target.value

  _focus : ->
    @refs.text.focus()
}

module.exports = TextEntry

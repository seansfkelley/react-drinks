# @cjsx React.DOM

React = require 'react'

SearchBar = React.createClass {
  displayName : 'SearchBar'

  propTypes :
    onChange    : React.PropTypes.func.isRequired
    placeholder : React.PropTypes.string

  getInitialState : ->
    return {
      value : ''
    }

  render : ->
    <div className='search-bar'>
      <input
        className='search-input'
        type='text'
        placeholder={@props.placeholder}
        ref='input'
        onChange={@_onChange}
        autoCorrect='off'
        autoCapitalize='off'
        autoComplete='off'
        spellCheck='false'
        tabIndex=-1
      />
      <i className='fa fa-times-circle' onTouchTap={@clearAndFocus} onTouchStart={@_stopTouchStart}/>
    </div>

  clearAndFocus : ->
    @clear()
    @focus()

  clear : ->
    @refs.input.getDOMNode().value = ''
    @props.onChange ''

  focus : ->
    @refs.input.getDOMNode().focus()

  isFocused : ->
    return document.activeElement == @refs.input.getDOMNode()

  _onChange : (e) ->
    @props.onChange e.target.value

  _stopTouchStart : (e) ->
    # This is hacky, but both of these are independently necessary.
    # 1. Stop propagation so that the App-level handler doesn't deselect the input on clear.
    e.stopPropagation()
    # 2. Prevent default so that iOS doesn't reassign the active element and deselect the input.
    e.preventDefault()
}

module.exports = SearchBar

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
      <input className='search-input' type='text' ref='input' onChange={@_onChange}
          autoCorrect='off' autoCapitalize='off' autoComplete='off' spellCheck='false' placeholder={@props.placeholder}/>
      <i className='fa fa-times-circle' onTouchTap={@clearAndFocus} data-autoblur='false'/>
    </div>

  clearAndFocus : ->
    @clear()
    @focus()

  clear : ->
    @refs.input.getDOMNode().value = ''
    @props.onChange ''

  focus : ->
    @refs.input.getDOMNode().focus()

  _onChange : (e) ->
    @props.onChange e.target.value
}

module.exports = SearchBar

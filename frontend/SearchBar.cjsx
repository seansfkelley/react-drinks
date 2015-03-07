# @cjsx React.DOM

React = require 'react'

SearchBar = React.createClass {
  getInitialState : ->
    return {
      value : ''
    }

  render : ->
    <div className='search-bar'>
      <input className='search-input' type='text' ref='input' onChange={@_onChange}/>
      <i className='fa fa-times-circle' onClick={@clearAndFocus}/>
    </div>

  clearAndFocus : ->
    @clear()
    @focus()

  clear : ->
    input = @refs.input.getDOMNode()
    input.value = ''
    @props.onChange ''

  focus : ->
    input = @refs.input.getDOMNode()
    input.focus()
    @props.onChange ''

  _onChange : (event) ->
    @props.onChange event.target.value
}

module.exports = SearchBar

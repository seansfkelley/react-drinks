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
    @refs.input.getDOMNode().value = ''
    @props.onChange ''

  focus : ->
    @refs.input.getDOMNode().focus()

  _onChange : (event) ->
    @props.onChange event.target.value
}

module.exports = SearchBar

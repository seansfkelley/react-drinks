# @cjsx React.DOM

React = require 'react'

ListHeader = React.createClass {
  render : ->
    <div className='list-header'>
      <span className='text'>{@props.title}</span>
    </div>
}

module.exports = ListHeader
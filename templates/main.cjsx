# @cjsx React.DOM

# TODO: Why is it necessary to explicitly require this?
React = require 'react'

Test = React.createClass {
  render : ->
    <div>herro</div>
}

module.exports = Test

# @cjsx React.DOM

React = require 'react'

AppDispatcher = require './AppDispatcher'

FavoritesList = React.createClass {
  render : ->
    <div onTouchTap={@_close}>stuff</div>

  _close : ->
    AppDispatcher.dispatch {
      type : 'hide-pushover'
    }
}

module.exports = FavoritesList

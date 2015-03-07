# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

AppDispatcher = require './AppDispatcher'

OverlayView = React.createClass {
  render : ->
    <div className={@props.className}>
      {@props.children}
    </div>
}

MODAL_TYPES = [ 'modal', 'flyup' ]
DOM_ELEMENT = document.querySelector '#overlay-root'

attachOverlayViews = ->
  shouldHide = false

  _.each MODAL_TYPES, (type) ->
    show = (component) ->
      shouldHide = false
      React.render <OverlayView className={type}>{component}</OverlayView>, DOM_ELEMENT
      _.defer ->
        DOM_ELEMENT.classList.add 'visible'

    hide = ->
      DOM_ELEMENT.classList.remove 'visible'
      # TODO: Fix this implementation; shouldHide is a hack.
      shouldHide = true
      _.delay (->
        if shouldHide
          React.unmountComponentAtNode DOM_ELEMENT
      ), 1000

    AppDispatcher.register (payload) ->
      switch payload.type
        when 'show-' + type
          show payload.component
        when 'hide-' + type
          hide()

      return true

module.exports = { attachOverlayViews }

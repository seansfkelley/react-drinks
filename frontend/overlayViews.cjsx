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
ROOT_OVERLAY_ELEMENT = document.querySelector '#overlay-root'

attachOverlayViews = ->
  # TODO (maybe): When showing a new thing, add a class to pop it over everything else.
  _.each MODAL_TYPES, (type) ->
    shouldHide = false
    domElement = ROOT_OVERLAY_ELEMENT.querySelector '.' + type

    show = (component) ->
      shouldHide = false
      React.render component, domElement
      _.defer ->
        domElement.classList.add 'visible'

    hide = ->
      domElement.classList.remove 'visible'
      # TODO: Fix this implementation; shouldHide is a hack.
      shouldHide = true
      _.delay (->
        if shouldHide
          React.unmountComponentAtNode domElement
      ), 1000

    AppDispatcher.register (payload) ->
      switch payload.type
        when 'show-' + type
          show payload.component
        when 'hide-' + type
          hide()

      return true

module.exports = { attachOverlayViews }

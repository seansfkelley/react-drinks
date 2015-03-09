# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

AppDispatcher = require './AppDispatcher'

MODAL_TYPES = [ 'modal', 'flyup' ]

attachOverlayViews = ->
  # Note that this implementation is very fragile to the ordering of the container elements in the DOM.
  # TODO (maybe): When showing a new thing, add a class to pop it over everything else.
  _.each MODAL_TYPES, (type) ->
    shouldHide = false
    domElement = document.querySelector "##{type}-root"

    show = (component) ->
      shouldHide = false
      React.render <div className='content'>{component}</div>, domElement
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

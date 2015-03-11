# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

AppDispatcher = require './AppDispatcher'

MODAL_TYPES = [ 'modal', 'flyup', 'pushover' ]

appRootElement = document.querySelector '#app-root'

attachOverlayViews = ->
  allDomElements = []

  _.each MODAL_TYPES, (type) ->
    shouldHide = false
    domElement = document.querySelector "##{type}-root"
    allDomElements.push domElement

    show = (component) ->
      shouldHide = false
      React.render <div className='content'>{component}</div>, domElement
      for e in allDomElements
        e.classList.remove 'topmost'
      appRootElement.classList.add "showing-#{type}"
      domElement.classList.add 'topmost'
      _.defer ->
        domElement.classList.add 'visible'

    hide = ->
      appRootElement.classList.remove "showing-#{type}"
      domElement.classList.remove 'visible'
      # TODO: Fix this implementation; shouldHide is a hack.
      shouldHide = true
      _.delay (->
        if shouldHide
          React.unmountComponentAtNode domElement
      # This should match up with the duration of animations in the syling to avoid situations in which
      # the panel exists but is off screen before/after animations.
      ), 333

    AppDispatcher.register (payload) ->
      switch payload.type
        when 'show-' + type
          show payload.component
        when 'hide-' + type
          hide()

      return true

module.exports = { attachOverlayViews }

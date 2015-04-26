_     = require 'lodash'
React = require 'react/addons'

AppDispatcher    = require './AppDispatcher'
stylingConstants = require './stylingConstants'

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
      React.render component, domElement
      for e in allDomElements
        e.classList.remove 'topmost'
      appRootElement.classList.add "showing-#{type}"
      appRootElement.classList.add 'showing-overlay'
      domElement.classList.add 'topmost'
      _.defer ->
        domElement.classList.add 'visible'

    hide = ->
      appRootElement.classList.remove "showing-#{type}"
      appRootElement.classList.remove 'showing-overlay'
      domElement.classList.remove 'visible'
      # TODO: Fix this implementation; shouldHide is a hack.
      shouldHide = true
      _.delay (->
        if shouldHide
          React.unmountComponentAtNode domElement
      ), stylingConstants.TRANSITION_DURATION

    AppDispatcher.register (payload) ->
      switch payload.type
        when 'show-' + type
          show payload.component
        when 'hide-' + type
          hide()

      return true

module.exports = { attachOverlayViews }

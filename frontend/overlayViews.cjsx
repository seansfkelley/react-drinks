_        = require 'lodash'
ReactDom = require 'react-dom'

stylingConstants = require './stylingConstants'

MODAL_TYPES = [ 'modal', 'flyup', 'pushover' ]

overlayViews = {}

do ->
  allDomElements = []

  _.each MODAL_TYPES, (type) ->
    shouldHide = false
    domElement = document.querySelector "##{type}-root"
    allDomElements.push domElement

    overlayViews[type] = {
      show : (component) ->
        shouldHide = false
        ReactDom.render component, domElement
        for e in allDomElements
          e.classList.remove 'topmost'
        document.body.classList.add "showing-#{type}"
        document.body.classList.add 'showing-overlay'
        domElement.classList.add 'topmost'
        # For some reason, this doesn't work for flyup when only done once. wtf.
        requestAnimationFrame ->
          requestAnimationFrame ->
            domElement.classList.add 'visible'

      hide : ->
        document.body.classList.remove "showing-#{type}"
        document.body.classList.remove 'showing-overlay'
        domElement.classList.remove 'visible'
        # TODO: Fix this implementation; shouldHide is a hack.
        shouldHide = true
        _.delay (->
          if shouldHide
            ReactDom.unmountComponentAtNode domElement
        ), stylingConstants.TRANSITION_DURATION
    }

module.exports = overlayViews

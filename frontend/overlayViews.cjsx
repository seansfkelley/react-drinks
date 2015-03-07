# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

AppDispatcher = require './AppDispatcher'

OverlayView = React.createClass {
  render : ->
    <div className='overlay'>
      {@props.children}
    </div>
}

FlyupView = React.createClass {
  render : ->
    <div className='flyup'>
      {@props.children}
    </div>
}

flyupRoot = document.querySelector '#flyup-root'
overlayRoot = document.querySelector '#overlay-root'

attachOverlayViews = ->
  showOverlay = (component) ->
    React.render <OverlayView>{component}</OverlayView>, overlayRoot

  hideOverlay = ->
    # React.unmountComponentAtNode overlayRoot

  shouldHide = false

  showFlyup = (component) ->
    shouldHide = false
    React.render <FlyupView>{component}</FlyupView>, flyupRoot
    _.defer ->
      flyupRoot.classList.add 'visible'

  hideFlyup = ->
    flyupRoot.classList.remove 'visible'
    # TODO: Fix this implementation.
    # TODO: Why is this implementation so divergent from overlay? Shouldn't they be basically the same with different styling?
    shouldHide = true
    _.delay (->
      if shouldHide
        React.unmountComponentAtNode flyupRoot
    ), 1000

  AppDispatcher.register (payload) ->
    switch payload.type
      when 'show-overlay'
        hideOverlay()
        showOverlay payload.component
      when 'hide-overlay'
        hideOverlay()
      when 'show-flyup'
        showFlyup payload.component
      when 'hide-flyup'
        hideFlyup()

    return true

module.exports = { attachOverlayViews }

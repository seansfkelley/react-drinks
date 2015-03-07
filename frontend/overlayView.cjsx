# @cjsx React.DOM

React = require 'react'

AppDispatcher = require './AppDispatcher'

OverlayView = React.createClass {
  render : ->
    <div className='overlay'>
      {@props.children}
    </div>
}

overlayRoot = document.querySelector '#overlay-root'

attachOverlayView = ->
  hide = ->
    React.unmountComponentAtNode overlayRoot
  show = (component) ->
    React.render <OverlayView>{component}</OverlayView>, overlayRoot

  AppDispatcher.register (payload) ->
    switch payload.type
      when 'show-overlay'
        hide()
        show payload.component
      when 'hide-overlay'
        hide()

    return true

module.exports = { attachOverlayView }

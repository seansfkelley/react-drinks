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
  show = (component) ->
    React.render <OverlayView>{component}</OverlayView>, overlayRoot

  hide = ->
    React.unmountComponentAtNode overlayRoot

  AppDispatcher.register (payload) ->
    switch payload.type
      when 'show-overlay'
        hide()
        show payload.component
      when 'hide-overlay'
        hide()

    return true

module.exports = { attachOverlayView }

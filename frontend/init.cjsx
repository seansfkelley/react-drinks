# @cjsx React.DOM

React = require 'react'

App = require './App'

if window.navigator.standalone
  document.body.setAttribute 'standalone', true

React.initializeTouchEvents true
require('./overlayViews').attachOverlayViews()
require('bluebird').longStackTraces()
require('react-tap-event-plugin')()

window.getJquery = ->
  jq = document.createElement 'script'
  jq.src = 'https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.js'
  document.getElementsByTagName('head')[0].appendChild jq

_oldOnTouchStart = document.ontouchstart
document.ontouchstart = (e) ->
  # This autoblur attribute is kind of a hack, cause we don't want clearing the search input
  # to unfocus it (cause you touched something else) and then immediately refocus it.
  if e.target.nodeName != 'INPUT' and e.target.dataset.autoblur != 'false'
    document.activeElement.blur()
  return _oldOnTouchStart?(arguments...)

React.render <App/>, document.querySelector('#app-root')

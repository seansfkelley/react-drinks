# @cjsx React.DOM

React = require 'react'

App = require './App'

if window.navigator.standalone
  document.body.setAttribute 'standalone', true

React.initializeTouchEvents true
require('./overlayViews').attachOverlayViews()
require('bluebird').longStackTraces()
require('react-tap-event-plugin')()

# if window.ontouchstart?
#   kill = (type) ->
#     window.document.body.addEventListener(type, (e) ->
#       e.preventDefault()
#       e.stopPropagation()
#       return false
#     , true)

#   for type in [ 'mousedown', 'mouseup', 'mousemove', 'click' ]
#     kill type

window.getJquery = ->
  jq = document.createElement 'script'
  jq.src = 'https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.js'
  document.getElementsByTagName('head')[0].appendChild jq

window.debug.log = require 'loglevel'

React.render <App/>, document.querySelector('#app-root')

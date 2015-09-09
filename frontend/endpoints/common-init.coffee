_     = require 'lodash'
React = require 'react'

# Probably not necessary for some views, but it's nice to have it here.
store       = require '../store'
persistence = require '../store/persistence'

module.exports = ->
  if window.navigator.standalone
    document.body.setAttribute 'standalone', true

  React.initializeTouchEvents true
  require('react-tap-event-plugin')()

  persistence.watch store

  # if 'ontouchstart' of window
  #   kill = (type) ->
  #     window.document.addEventListener(type, (e) ->
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

  window.debug = {
    log          : require 'loglevel'
    localStorage : ->
      return _.mapValues localStorage, (v) ->
        try
          return JSON.parse v
        catch
          return v
    getState : ->
      return store.getState()
  }

  # For devtools.
  window.React = React
  # Becaues I use it a lot.
  window._ = _

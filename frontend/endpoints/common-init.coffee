_ = require 'lodash'

module.exports = _.once ->
  require('bluebird').longStackTraces()

  if window.navigator.standalone
    document.body.setAttribute 'standalone', true

  require('react-tap-event-plugin')()

  # if 'ontouchstart' of window
  #   kill = (type) ->
  #     window.document.addEventListener(type, (e) ->
  #       e.preventDefault()
  #       e.stopPropagation()
  #       return false
  #     , true)

  #   for type in [ 'mousedown', 'mouseup', 'mousemove', 'click' ]
  #     kill type

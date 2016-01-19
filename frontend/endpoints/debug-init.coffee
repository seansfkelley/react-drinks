_         = require 'lodash'
React     = require 'react'
ReactPerf = require 'react-addons-perf'
reqwest   = require 'reqwest'

module.exports = _.once ->
  window.getJquery = ->
    jq = document.createElement 'script'
    jq.src = 'https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.js'
    document.getElementsByTagName('head')[0].appendChild jq

  window.reactPerf = ReactPerf

  window.debug = {
    log : require 'loglevel'

    localStorage : ->
      return _.mapValues localStorage, (v) ->
        try
          return JSON.parse v
        catch
          return v

    clearLocalStorage : ({ force } = { force : false })->
      if not force
        console.error 'pass the \'force\' option if you really mean it'
      else
        delete localStorage['drinks-app-persistence']

    dispatch : ->
      return require('../store').dispatch(arguments...)

    getState : ->
      return require('../store').getState()

    reactPerf : (timeout = 2000) ->
      ReactPerf.start()
      setTimeout (->
        ReactPerf.stop()
        ReactPerf.printWasted()
      ), timeout
  }

  # For devtools.
  window.React = React
  # Because I use these a lot.
  window._ = _
  window.reqwest = reqwest

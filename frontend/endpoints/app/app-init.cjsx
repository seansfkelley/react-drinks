require('../common-init')()

# Kick off requests ASAP.
initializationPromise = require('../../store/init')()

_        = require 'lodash'
ReactDOM = require 'react-dom'
Promise  = require 'bluebird'

App                 = require './App'
webClipNotification = require './webClipNotification'

store       = require '../../store'
derived     = require '../../store/derived'
persistence = require '../../store/persistence'

LOADING_OVERLAY = document.querySelector '#main-loading-overlay'
APP_ROOT        = document.querySelector '#app-root'

# By racing these, we ensure we don't pop up the text right as the overlay is fading out.
Promise.any [
  Promise.delay(3000).return true
  initializationPromise.return false
]
.then (showText) ->
  if showText
    LOADING_OVERLAY.classList.add 'show-waiting-text'

initializationPromise.then ->
  persistence.watch store

  ReactDOM.render <App/>, APP_ROOT

  LOADING_OVERLAY.classList.add 'fade-out'

  webClipNotification.renderIfAppropriate()

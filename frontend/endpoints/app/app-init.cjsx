require('../common-init')()
require('../debug-init')()

# Kick off requests ASAP.
initializationPromise = require('../../store/init')()

_        = require 'lodash'
ReactDOM = require 'react-dom'
Promise  = require 'bluebird'

App                 = require './App'
ErrorMessageOverlay = require '../../components/ErrorMessageOverlay'
webClipNotification = require './webClipNotification'

store       = require '../../store'
derived     = require '../../store/derived'
persistence = require '../../store/persistence'

LOADING_OVERLAY    = document.querySelector '#main-loading-overlay'
APP_ROOT           = document.querySelector '#app-root'
ERROR_MESSAGE_ROOT = document.querySelector '#error-message-root'

onUnhandledError = ->
  # TODO: Ship this back to the server for debuggin'.
  store.dispatch {
    type    : 'error-message'
    message : 'Uh oh, something bad happened! Try reloading to fix it.'
  }

Promise.onPossiblyUnhandledRejection onUnhandledError
window.onerror = onUnhandledError

# By racing these, we ensure we don't pop up the text right as the overlay is fading out.
Promise.any [
  Promise.delay(3000).return true
  initializationPromise.return false
]
.then (showText) ->
  if showText
    LOADING_OVERLAY.classList.add 'show-waiting-text'

initializationPromise
.then ->
  persistence.watch store
  # The idea is to refresh the timestamps, even if the user doesn't interact. Opening the app
  # should be sufficient interaction to reset the timers on all the expirable pieces of state.
  store.dispatch {
    type : '--dummy-event-to-trigger-persistence--'
  }

  ReactDOM.render <App/>, APP_ROOT

  webClipNotification.renderIfAppropriate()

  LOADING_OVERLAY.classList.add 'fade-out'

.catch ->
  store.dispatch {
    type    : 'error-message'
    message : 'There was an error loading data from the server! Try reloading.'
  }

ReactDOM.render <ErrorMessageOverlay/>, ERROR_MESSAGE_ROOT

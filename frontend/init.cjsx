window.debug = {}

React = require 'react/addons'

App      = require './App'
FtueView = require './FtueView'
stores   = require './stores'

{ UiStore, IngredientStore } = stores

# Initialize state.

initializationPromise = stores.seedStores()

if window.navigator.standalone
  document.body.setAttribute 'standalone', true

React.initializeTouchEvents true
require('./overlayViews').attachOverlayViews()
require('bluebird').longStackTraces()
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

# Show views.

LOADING_OVERLAY = document.querySelector '#main-loading-overlay'
FTUE_ROOT       = document.querySelector '#ftue-root'
APP_ROOT        = document.querySelector '#app-root'

initializationPromise.then ->
  if not UiStore.completedFtue
    FTUE_ROOT.classList.remove 'display-none'
    React.render <FtueView
      alphabeticalIngredients={IngredientStore.alphabeticalIngredients}
      initialSelectedIngredientTags={IngredientStore.selectedIngredientTags}
      onComplete={-> FTUE_ROOT.classList.add 'fade-out'}
    />, FTUE_ROOT

  React.render <App/>, APP_ROOT

  LOADING_OVERLAY.classList.add 'fade-out'

# Debugging.

window.getJquery = ->
  jq = document.createElement 'script'
  jq.src = 'https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.js'
  document.getElementsByTagName('head')[0].appendChild jq

window.debug.log = require 'loglevel'
# For devtools.
window.React = React

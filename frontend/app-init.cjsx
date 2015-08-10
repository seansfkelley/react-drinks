require('./common-init')()

React = require 'react/addons'

App           = require './App'
FtueView      = require './FtueView'
AppDispatcher = require './AppDispatcher'
stores        = require './stores'

{ UiStore, IngredientStore } = stores

# Initialize state.

require('bluebird').longStackTraces()
initializationPromise = stores.seedStores()

# Show views.

LOADING_OVERLAY = document.querySelector '#main-loading-overlay'
FTUE_ROOT       = document.querySelector '#ftue-root'
APP_ROOT        = document.querySelector '#app-root'

initializationPromise.then ->
  if not UiStore.completedFtue
    completeFtue = ->
      FTUE_ROOT.classList.add 'fade-out'
      AppDispatcher.dispatch {
        type : 'completed-ftue'
      }

    FTUE_ROOT.classList.remove 'display-none'
    React.render <FtueView onComplete={completeFtue}/>, FTUE_ROOT

  React.render <App/>, APP_ROOT

  LOADING_OVERLAY.classList.add 'fade-out'

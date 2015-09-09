require('../common-init')()

_     = require 'lodash'
React = require 'react/addons'

App                 = require './App'
webClipNotification = require './webClipNotification'

AppDispatcher = require '../../AppDispatcher'
stores        = require '../../stores'

SwipableRecipeView = require '../../recipes/SwipableRecipeView'

{ UiStore, RecipeStore } = stores

# Initialize state.

require('bluebird').longStackTraces()
initializationPromise = stores.seedStores()

# Show views.

LOADING_OVERLAY = document.querySelector '#main-loading-overlay'
APP_ROOT        = document.querySelector '#app-root'

initializationPromise.then ->
  React.render <App/>, APP_ROOT

  if UiStore.recipeViewingIndex?
    SwipableRecipeView.showInModal RecipeStore.filteredAlphabeticalRecipes, UiStore.recipeViewingIndex

  LOADING_OVERLAY.classList.add 'fade-out'

  webClipNotification.renderIfAppropriate()

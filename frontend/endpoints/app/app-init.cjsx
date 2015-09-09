require('../common-init')()

_     = require 'lodash'
React = require 'react/addons'

App                 = require './App'
webClipNotification = require './webClipNotification'

store   = require '../../store'
derived = require '../../store/derived'

SwipableRecipeView = require '../../recipes/SwipableRecipeView'

# Initialize state.

require('bluebird').longStackTraces()
initializationPromise = require('../../store/init')()

# Show views.

LOADING_OVERLAY = document.querySelector '#main-loading-overlay'
APP_ROOT        = document.querySelector '#app-root'

initializationPromise.then ->
  React.render <App/>, APP_ROOT

  state = store.getState()

  if state.ui.recipeViewingIndex?
    SwipableRecipeView.showInModal(
      derived.filteredGroupedAlphabeticalRecipes(state)
      state.ui.recipeViewingIndex
    )

  LOADING_OVERLAY.classList.add 'fade-out'

  webClipNotification.renderIfAppropriate()
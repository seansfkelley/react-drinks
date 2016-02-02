require('../common-init')()

React    = require 'react'
ReactDOM = require 'react-dom'

StandaloneRecipe = require './StandaloneRecipe'

APP_ROOT = document.querySelector '#app-root'

# TODO: Redirect to nonexistent error page if this is mangled.
ReactDOM.render <StandaloneRecipe recipe={window.recipeData}/>, APP_ROOT

require('../common-init')()

ReactDOM = require 'react-dom'

StandaloneRecipe = require './StandaloneRecipe'

APP_ROOT = document.querySelector '#app-root'

# TODO: Redirect to nonexistent error page if this is mangled.
ReactDOM.render <StandaloneRecipe recipe={window.recipeData}/>, APP_ROOT

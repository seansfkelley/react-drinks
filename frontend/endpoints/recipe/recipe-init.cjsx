require('../common-init')()

ReactDom = require 'react-dom'

StandaloneRecipe = require './StandaloneRecipe'

APP_ROOT = document.querySelector '#app-root'

# TODO: Redirect to nonexistent error page if this is mangled.
ReactDom.render <StandaloneRecipe recipe={window.recipeData}/>, APP_ROOT

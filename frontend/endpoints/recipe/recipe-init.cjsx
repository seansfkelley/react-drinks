require('../common-init')()

ReactDom = require 'react-dom'

RecipeView = require '../../recipes/RecipeView'

APP_ROOT = document.querySelector '#app-root'

# TODO: Redirect to nonexistent error page if this is mangled.
# TODO: Link back to home page!
ReactDom.render <RecipeView recipe={window.recipeData}/>, APP_ROOT

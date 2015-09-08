require('../common-init')()

React = require 'react/addons'

RecipeView = require '../../recipes/RecipeView'

APP_ROOT = document.querySelector '#app-root'

# TODO: Redirect to nonexistent error page if this is mangled.
# TODO: Link back to home page!
React.render <RecipeView recipe={window.recipeData}/>, APP_ROOT

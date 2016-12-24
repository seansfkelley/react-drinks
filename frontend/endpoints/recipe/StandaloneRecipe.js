React = require 'react'

definitions = require '../../../shared/definitions'

TitleBar = require '../../components/TitleBar'

RecipeView = require '../../recipes/RecipeView'

StandaloneRecipeView = React.createClass {
  displayName : 'StandaloneRecipeView'

  propTypes :
    recipe : React.PropTypes.object.isRequired

  render : ->
    React.createElement("div", {"className": 'standalone-recipe'},
      React.createElement("a", {"className": 'homepage-link', "href": (definitions.BASE_URL), "target": '_blank'},
        React.createElement(TitleBar, null, "Spirit Guide", React.createElement("i", {"className": 'fa fa-chevron-right'})
        )
      ),
      React.createElement(RecipeView, {"recipe": (@props.recipe)})
    )
}

module.exports = StandaloneRecipeView

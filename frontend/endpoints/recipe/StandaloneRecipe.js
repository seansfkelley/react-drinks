const React = require('react');

const definitions = require('../../../shared/definitions');

const TitleBar = require('../../components/TitleBar');

const RecipeView = require('../../recipes/RecipeView');

const StandaloneRecipeView = React.createClass({
  displayName : 'StandaloneRecipeView',

  propTypes : {
    recipe : React.PropTypes.object.isRequired
  },

  render() {
    return React.createElement("div", {"className": 'standalone-recipe'},
      React.createElement("a", {"className": 'homepage-link', "href": (definitions.BASE_URL), "target": '_blank'},
        React.createElement(TitleBar, null, "Spirit Guide", React.createElement("i", {"className": 'fa fa-chevron-right'})
        )
      ),
      React.createElement(RecipeView, {"recipe": (this.props.recipe)})
    );
  }
});

module.exports = StandaloneRecipeView;

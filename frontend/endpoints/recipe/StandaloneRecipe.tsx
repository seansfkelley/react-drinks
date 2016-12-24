const React = require('react');

const definitions = require('../../../shared/definitions');

const TitleBar = require('../../components/TitleBar');

const RecipeView = require('../../recipes/RecipeView');

const StandaloneRecipeView = React.createClass({
  displayName: 'StandaloneRecipeView',

  propTypes: {
    recipe: React.PropTypes.object.isRequired
  },

  render() {
    return <div className='standalone-recipe'><a className='homepage-link' href={definitions.BASE_URL} target='_blank'><TitleBar>Spirit Guide<i className='fa fa-chevron-right' /></TitleBar></a><RecipeView recipe={this.props.recipe} /></div>;
  }
});

module.exports = StandaloneRecipeView;
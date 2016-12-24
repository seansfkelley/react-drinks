import {} from 'lodash';
const React = require('react');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const ReduxMixin = require('../mixins/ReduxMixin');
const DerivedValueMixin = require('../mixins/DerivedValueMixin');

const Swipable = require('../components/Swipable');

const store = require('../store');

const RecipeView = require('./RecipeView');

const SwipableRecipeView = React.createClass({
  displayName: 'SwipableRecipeView',

  propTypes: {
    onClose: React.PropTypes.func.isRequired
  },

  mixins: [ReduxMixin({
    recipes: 'recipesById',
    ingredients: 'ingredientsByTag',
    ui: ['favoritedRecipeIds', 'currentlyViewedRecipeIds', 'recipeViewingIndex']
  }), DerivedValueMixin(['ingredientSplitsByRecipeId']), PureRenderMixin],

  render() {
    if (this.state.currentlyViewedRecipeIds.length === 0) {
      return <div />;
    } else {
      const recipePages = _.map(this.state.currentlyViewedRecipeIds, (recipeId, i) => {
        return <div className='swipable-padding-wrapper' key={recipeId}>{Math.abs(i - this.state.recipeViewingIndex) <= 1 ? this._renderRecipe(this.state.recipesById[recipeId]) : undefined}</div>;
      });

      return <Swipable className='swipable-recipe-container' initialIndex={this.state.recipeViewingIndex} onSlideChange={this._onSlideChange} friction={0.9}>{recipePages}</Swipable>;
    }
  },

  _renderRecipe(recipe) {
    return <div className='swipable-position-wrapper'><RecipeView recipe={recipe} ingredientsByTag={this.state.ingredientsByTag} ingredientSplits={__guard__(this.state.ingredientSplitsByRecipeId, x => x[recipe.recipeId])} onClose={this._onClose} onFavorite={this._onFavorite} onEdit={recipe.isCustom ? this._onEdit : undefined} isFavorited={this.state.favoritedRecipeIds.includes(recipe.recipeId)} isShareable={true} /></div>;
  },

  _onSlideChange(index) {
    return store.dispatch({
      type: 'set-recipe-viewing-index',
      index
    });
  },

  _onClose() {
    store.dispatch({
      type: 'set-recipe-viewing-index',
      index: 0
    });

    return this.props.onClose();
  },

  _onEdit(recipe) {
    store.dispatch({
      type: 'seed-recipe-editor',
      recipe
    });

    return store.dispatch({
      type: 'show-recipe-editor'
    });
  },

  _onFavorite(recipe, shouldFavorite) {
    if (shouldFavorite) {
      return store.dispatch({
        type: 'favorite-recipe',
        recipeId: recipe.recipeId
      });
    } else {
      return store.dispatch({
        type: 'unfavorite-recipe',
        recipeId: recipe.recipeId
      });
    }
  }
});

module.exports = SwipableRecipeView;

function __guard__(value, transform) {
  return typeof value !== 'undefined' && value !== null ? transform(value) : undefined;
}

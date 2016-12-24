const _ = require('lodash');
const React = require('react');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const ReduxMixin = require('../mixins/ReduxMixin');
const DerivedValueMixin = require('../mixins/DerivedValueMixin');

const SearchBar = require('../components/SearchBar');
const List = require('../components/List');

const store = require('../store');
const utils = require('../utils');
const stylingConstants = require('../stylingConstants');
const Difficulty = require('../Difficulty');

const RecipeListItem = require('./RecipeListItem');
const RecipeListHeader = require('./RecipeListHeader');

const RecipeList = React.createClass({
  displayName: 'RecipeList',

  propTypes: {
    recipes: React.PropTypes.array.isRequired,
    ingredientsByTag: React.PropTypes.object.isRequired,
    favoritedRecipeIds: React.PropTypes.array.isRequired,
    ingredientSplitsByRecipeId: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  render() {
    const recipeCount = _.chain(this.props.recipes).pluck('recipes').pluck('length').reduce((sum, l) => sum + l, 0).value();

    const listNodes = [];
    let absoluteIndex = 0;
    for (let { key, recipes } of this.props.recipes) {
      if (recipeCount > 6) {
        listNodes.push(this._makeHeader(key, recipes));
      }
      for (let r of recipes) {
        listNodes.push(this._makeItem(key, r, absoluteIndex));
        absoluteIndex += 1;
      }
    }

    return <List className={List.ClassNames.HEADERED}>{listNodes}</List>;
  },

  _makeHeader(groupKey, recipes) {
    return <List.Header title={groupKey.toUpperCase()} key={`header-${ groupKey }`} />;
  },

  _makeItem(groupKey, r, absoluteIndex) {
    let difficulty, isMixable;
    const missingIngredients = this.props.ingredientSplitsByRecipeId[r.recipeId].missing;
    if (missingIngredients.length) {
      isMixable = false;
      difficulty = Difficulty.getHardest(_.chain(missingIngredients).pluck('tag').map(tag => this.props.ingredientsByTag[tag]).pluck('difficulty').value());
    }

    // TODO: This can cause needless rerenders, especially when text-searching.
    // PureRenderMixin is bypassed since .bind() returns a new function every time.
    // Is there a way to always pass the same function and infer the index from the event?
    return <RecipeListItem difficulty={difficulty} isMixable={isMixable} recipeName={r.name} onTouchTap={this._showRecipeViewer.bind(this, absoluteIndex)} onDelete={r.isCustom ? this._deleteRecipe.bind(null, r.recipeId) : undefined} key={r.recipeId} />;
  },

  _showRecipeViewer(index) {
    const recipeIds = _.chain(this.props.recipes).pluck('recipes').flatten().pluck('recipeId').value();

    return store.dispatch({
      type: 'show-recipe-viewer',
      recipeIds,
      index
    });
  },

  _deleteRecipe(recipeId) {
    return store.dispatch({
      type: 'delete-recipe',
      recipeId
    });
  }
});

const RecipeListView = React.createClass({
  displayName: 'RecipeListView',

  propTypes: {},

  mixins: [ReduxMixin({
    filters: ['recipeSearchTerm', 'baseLiquorFilter'],
    ingredients: 'ingredientsByTag',
    ui: 'favoritedRecipeIds'
  }), DerivedValueMixin(['filteredGroupedRecipes', 'ingredientSplitsByRecipeId']), PureRenderMixin],

  render() {
    return <div className='recipe-list-view fixed-header-footer'><RecipeListHeader /><div className='fixed-content-pane' ref='content'><SearchBar className='list-topper' initialValue={this.state.recipeSearchTerm} placeholder='Name or ingredient...' onChange={this._onSearch} ref='search' /><RecipeList recipes={this.state.filteredGroupedRecipes} ingredientsByTag={this.state.ingredientsByTag} ingredientSplitsByRecipeId={this.state.ingredientSplitsByRecipeId} favoritedRecipeIds={this.state.favoritedRecipeIds} /></div></div>;
  },

  componentDidMount() {
    return this._attemptScrollDown();
  },

  componentDidUpdate(prevProps, prevState) {
    if (!this.refs.search.isFocused() && prevState.baseLiquorFilter !== this.state.baseLiquorFilter) {
      return this._attemptScrollDown();
    }
  },

  _attemptScrollDown: _.debounce(function () {
    return this.refs.content.scrollTop = stylingConstants.RECIPE_LIST_ITEM_HEIGHT - stylingConstants.RECIPE_LIST_HEADER_HEIGHT / 2;
  }),

  _onSearch(searchTerm) {
    return store.dispatch({
      type: 'set-recipe-search-term',
      searchTerm
    });
  }

});

module.exports = RecipeListView;
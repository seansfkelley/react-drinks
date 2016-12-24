import {} from 'lodash';
const React = require('react');
const classnames = require('classnames');
const Isvg = require('react-inlinesvg');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const ReduxMixin = require('../mixins/ReduxMixin');
const DerivedValueMixin = require('../mixins/DerivedValueMixin');

const store = require('../store');
const stylingConstants = require('../stylingConstants');

const SearchBar = require('../components/SearchBar');
const GroupedIngredientList = require('../ingredients/GroupedIngredientList');

const IngredientsSidebar = React.createClass({
  displayName: 'IngredientsSidebar',

  propTypes: {
    onClose: React.PropTypes.func.isRequired
  },

  mixins: [ReduxMixin({
    filters: 'selectedIngredientTags'
  }), DerivedValueMixin('filteredGroupedIngredients'), PureRenderMixin],

  render() {
    return <div className='ingredients-sidebar'><SearchBar placeholder='Ingredient name...' onChange={this._onSearch} /><GroupedIngredientList groupedIngredients={this.state.filteredGroupedIngredients} initialSelectedIngredientTags={this.state.selectedIngredientTags} onSelectionChange={this._onIngredientToggle} ref='ingredientList' /></div>;
  },

  _onSearch(searchTerm) {
    return store.dispatch({
      type: 'set-ingredient-search-term',
      searchTerm
    });
  },

  forceClose() {
    store.dispatch({
      type: 'set-selected-ingredient-tags',
      tags: this.refs.ingredientList.getSelectedTags()
    });
    return this.props.onClose();
  }
});

module.exports = IngredientsSidebar;

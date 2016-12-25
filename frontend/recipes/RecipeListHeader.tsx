import {} from 'lodash';
import * as React from 'react';
const classnames = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const definitions = require('../../shared/definitions');

const ReduxMixin = require('../mixins/ReduxMixin');

const TitleBar = require('../components/TitleBar');
const Swipable = require('../components/Swipable');

const store = require('../store');

const BASE_LIQUORS = [definitions.ANY_BASE_LIQUOR].concat(definitions.BASE_LIQUORS);

const RecipeListHeader = React.createClass({
  displayName: 'RecipeListHeader',

  mixins: [ReduxMixin({
    filters: ['baseLiquorFilter', 'selectedRecipeList']
  }), PureRenderMixin],

  render() {
    let initialBaseLiquorIndex = _.indexOf(BASE_LIQUORS, this.state.baseLiquorFilter);
    if (initialBaseLiquorIndex === -1) {
      initialBaseLiquorIndex = 0;
    }

    return <div className='recipe-list-header fixed-header'><TitleBar leftIcon='/assets/img/ingredients.svg' leftIconOnTouchTap={this._showSidebar} rightIcon='fa-plus' rightIconOnTouchTap={this._newRecipe} className='recipe-list-header' onClick={this._showListSelector}>{definitions.RECIPE_LIST_NAMES[this.state.selectedRecipeList]}<i className='fa fa-chevron-down' /></TitleBar><Swipable className='base-liquor-container' initialIndex={initialBaseLiquorIndex} onSlideChange={this._onBaseLiquorChange} friction={0.7}>{_.map(BASE_LIQUORS, base => {
          return <div className={classnames('base-liquor-option', { 'selected': base === this.state.baseLiquorFilter })} key={base}>{base}</div>;
        })}</Swipable></div>;
  },

  _onBaseLiquorChange(index) {
    return store.dispatch({
      type: 'set-base-liquor-filter',
      filter: BASE_LIQUORS[index]
    });
  },

  _showSidebar() {
    return store.dispatch({
      type: 'show-sidebar'
    });
  },

  _showListSelector() {
    return store.dispatch({
      type: 'show-list-selector'
    });
  },

  _newRecipe() {
    return store.dispatch({
      type: 'show-recipe-editor'
    });
  }
});

module.exports = RecipeListHeader;

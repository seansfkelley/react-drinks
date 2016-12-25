import * as React from 'react';
import * as classNames from 'classnames';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import { ANY_BASE_LIQUOR, BASE_LIQUORS, RECIPE_LIST_NAMES } from '../../shared/definitions';

import ReduxMixin from '../mixins/ReduxMixin';

import TitleBar from '../components/TitleBar';
import Swipable from '../components/Swipable';

import { store } from '../store';

const ALL_BASE_LIQUORS = [ANY_BASE_LIQUOR].concat(BASE_LIQUORS);

interface State {
  baseLiquorFilter: string;
  selectedRecipeList: string;
}

export default React.createClass<void, State>({
  displayName: 'RecipeListHeader',

  mixins: [
    ReduxMixin({
      filters: ['baseLiquorFilter', 'selectedRecipeList']
    }),
     PureRenderMixin
    ],

  render() {
    let initialBaseLiquorIndex = ALL_BASE_LIQUORS.indexOf(this.state.baseLiquorFilter);
    if (initialBaseLiquorIndex === -1) {
      initialBaseLiquorIndex = 0;
    }

    return (
      <div className='recipe-list-header fixed-header'>
        <TitleBar
          leftIcon='/assets/img/ingredients.svg'
          leftIconOnClick={this._showSidebar}
          rightIcon='fa-plus'
          rightIconOnClick={this._newRecipe}
          className='recipe-list-header'
          onClick={this._showListSelector}
        >
          {(RECIPE_LIST_NAMES as any)[this.state.selectedRecipeList]}
          <i className='fa fa-chevron-down' />
        </TitleBar>
        <Swipable
          className='base-liquor-container'
          initialIndex={initialBaseLiquorIndex}
          onSlideChange={this._onBaseLiquorChange}
          friction={0.7}
        >
          {ALL_BASE_LIQUORS.map(base => (
            <div
              className={classNames('base-liquor-option', { 'selected': base === this.state.baseLiquorFilter })}
              key={base}
            >
                {base}
            </div>
          ))}
        </Swipable>
      </div>
    );
  },

  _onBaseLiquorChange(index: number) {
    store.dispatch({
      type: 'set-base-liquor-filter',
      filter: ALL_BASE_LIQUORS[index]
    });
  },

  _showSidebar() {
    store.dispatch({
      type: 'show-sidebar'
    });
  },

  _showListSelector() {
    store.dispatch({
      type: 'show-list-selector'
    });
  },

  _newRecipe() {
    store.dispatch({
      type: 'show-recipe-editor'
    });
  }
});

import * as React from 'react';
import * as classNames from 'classnames';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { ANY_BASE_LIQUOR, BASE_LIQUORS } from '../../shared/definitions';
import { RECIPE_LIST_NAMES } from '../constants';

import TitleBar from '../components/TitleBar';
import Swipable from '../components/Swipable';

import { RootState } from '../store';
import {
  showSidebar,
  showListSelector,
  setBaseLiquorFilter
} from '../store/atomicActions';

const ALL_BASE_LIQUORS = [ANY_BASE_LIQUOR].concat(BASE_LIQUORS);

interface ConnectedProps {
  baseLiquorFilter: string;
  selectedRecipeList: string;
}

interface DispatchProps {
  showSidebar: typeof showSidebar;
  showListSelector: typeof showListSelector;
  setBaseLiquorFilter: typeof setBaseLiquorFilter;
}

class RecipeListHeader extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  render() {
    let initialBaseLiquorIndex = ALL_BASE_LIQUORS.indexOf(this.props.baseLiquorFilter);
    if (initialBaseLiquorIndex === -1) {
      initialBaseLiquorIndex = 0;
    }

    return (
      <div className='recipe-list-header fixed-header'>
        <TitleBar
          leftIcon='/assets/img/ingredients.svg'
          leftIconOnClick={this.props.showSidebar}
          // rightIcon='fa-plus'
          // rightIconOnClick={this._newRecipe}
          className='recipe-list-header'
          onClick={this.props.showListSelector}
        >
          {(RECIPE_LIST_NAMES as any)[this.props.selectedRecipeList]}
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
              className={classNames('base-liquor-option', { 'selected': base === this.props.baseLiquorFilter })}
              key={base}
            >
                {base}
            </div>
          ))}
        </Swipable>
      </div>
    );
  }

  private _onBaseLiquorChange = (index: number) => {
    this.props.setBaseLiquorFilter(ALL_BASE_LIQUORS[index]);
  };
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    baseLiquorFilter: state.filters.baseLiquorFilter,
    selectedRecipeList: state.filters.selectedRecipeList
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    showSidebar,
    showListSelector,
    setBaseLiquorFilter
  }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(RecipeListHeader) as React.ComponentClass<void>;

import { without, flatten } from 'lodash';
import * as React from 'react';
import * as classNames from 'classnames';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { ORDERED_RECIPE_LIST_TYPES, RECIPE_LIST_NAMES } from '../constants';
import { RecipeListType } from '../types';
import { RootState } from '../store';
import {
  setSelectedRecipeList,
  hideListSelector
} from '../store/atomicActions';

interface ConnectedProps {
  currentType: string;
}

interface DispatchProps {
  setSelectedRecipeList: typeof setSelectedRecipeList;
  hideListSelector: typeof hideListSelector;
}

class RecipeListSelector extends React.PureComponent<ConnectedProps & DispatchProps, void> {

  render() {
    const reorderedOptions = flatten([this.props.currentType, without(ORDERED_RECIPE_LIST_TYPES, this.props.currentType)]);
    const options = reorderedOptions.map(type => (
      <div
        key={type}
        className={classNames('option', { 'is-selected': type === this.props.currentType })}
        onClick={this._onOptionSelect.bind(null, type)}
      >
        <span className='label'>{RECIPE_LIST_NAMES[type]}</span>
      </div>
    ));

    return <div className='recipe-list-selector'>{options}</div>;
  }

  private _onOptionSelect =(listType: RecipeListType) => {
    this.props.setSelectedRecipeList(listType);
    this.props.hideListSelector();
  };
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    currentType: state.filters.selectedRecipeList
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setSelectedRecipeList,
    hideListSelector
  }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(RecipeListSelector) as React.ComponentClass<void>;

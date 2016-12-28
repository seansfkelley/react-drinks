import * as React from 'react';
import { connect } from 'react-redux';
import { Dispatch, bindActionCreators } from 'redux';

import { GroupedIngredients } from '../types';
import { RootState } from '../store';
import { selectFilteredGroupedIngredients } from '../store/selectors';
import { setIngredientSearchTerm } from '../store/atomicActions';

import SearchBar from '../components/SearchBar';
import GroupedIngredientList from '../ingredients/GroupedIngredientList';

interface OwnProps {
  onPendingTagsChange: (tags: { [tag: string]: any }) => void;
}

interface ConnectedProps {
  selectedIngredientTags: string[];
  filteredGroupedIngredients: GroupedIngredients[];
}

interface DispatchProps {
  setIngredientSearchTerm: typeof setIngredientSearchTerm;
}

interface State {
  pendingSelectedIngredientTags: string[];
}

class IngredientsSidebar extends React.PureComponent<OwnProps & ConnectedProps & DispatchProps, State> {
  state: State = {
    pendingSelectedIngredientTags: this.props.selectedIngredientTags
  };

  render() {
    return (
      <div className='ingredients-sidebar'>
        <SearchBar placeholder='Ingredient name...' onChange={this.props.setIngredientSearchTerm} />
        <GroupedIngredientList
          groupedIngredients={this.props.filteredGroupedIngredients}
          selectedIngredientTags={this.state.pendingSelectedIngredientTags}
          onSelectionChange={this._updatePendingTags}
        />
      </div>
    );
  };

  componentWillReceiveProps(nextProps: ConnectedProps) {
    this.setState({ pendingSelectedIngredientTags: nextProps.selectedIngredientTags });
  }

  componentDidMount() {
    this.props.onPendingTagsChange(this.state.pendingSelectedIngredientTags);
  }

  componentDidUpdate() {
    this.props.onPendingTagsChange(this.state.pendingSelectedIngredientTags);
  }

  _updatePendingTags = (pendingSelectedIngredientTags: string[]) => {
    this.setState({ pendingSelectedIngredientTags });
  };
};

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    selectedIngredientTags: state.filters.selectedIngredientTags,
    filteredGroupedIngredients: selectFilteredGroupedIngredients(state)
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({ setIngredientSearchTerm }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(IngredientsSidebar) as React.ComponentClass<OwnProps>;

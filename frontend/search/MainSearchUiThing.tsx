import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { RootState } from '../store';
import { Ingredient } from '../../shared/types';
import {
  setSelectedIngredientTags
} from '../store/atomicActions';
import TitleBar from '../components/TitleBar';
import Tabs from '../components/Tabs';
import IngredientsSidebar from '../recipes/IngredientsSidebar';
import RecipeListView from '../recipes/RecipeListView';

interface ConnectedProps {
  selectedIngredientTags: string[];
  ingredientsByTag: { [tag: string]: Ingredient };
}

interface DispatchProps {
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
}

class MainSearchUiThing extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  render() {
    return (
      <div className='main-search-ui-thing'>
        <TitleBar
          leftIcon='fa-chevron-left'
          leftIconOnClick={this._popStack}
        >
          {this.props.selectedIngredientTags.length === 1
            ? this.props.ingredientsByTag[this.props.selectedIngredientTags[0]].display
            : `${this.props.selectedIngredientTags.length} Ingredients`}
        </TitleBar>
        <Tabs
          tabs={[{
            name: 'Ingredients'
          }, {
            name: 'Drinks'
          }]}
        >
          <IngredientsSidebar
            onPendingTagsChange={this.props.setSelectedIngredientTags}
          />
          <RecipeListView />
        </Tabs>
      </div>
    );
  }

  private _popStack = () => {
    this.props.setSelectedIngredientTags(this.props.selectedIngredientTags.slice(0, this.props.selectedIngredientTags.length - 1));
  };
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    selectedIngredientTags: state.filters.selectedIngredientTags,
    ingredientsByTag: state.ingredients.ingredientsByTag
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setSelectedIngredientTags
  }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(MainSearchUiThing) as React.ComponentClass<void>;

import { debounce } from 'lodash';
import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import SearchBar from '../components/SearchBar';

import { Ingredient } from '../../shared/types';
import { GroupedRecipes } from '../types';
import { IngredientSplit } from '../store/derived/ingredientSplitsByRecipeId';
import { RootState } from '../store';
import { selectFilteredGroupedRecipes, selectIngredientSplitsByRecipeId } from '../store/selectors';
import { setRecipeSearchTerm } from '../store/atomicActions';
import { RECIPE_LIST_ITEM_HEIGHT, RECIPE_LIST_HEADER_HEIGHT } from '../stylingConstants';

import RecipeList from './RecipeList';
import RecipeListHeader from './RecipeListHeader';

interface ConnectedProps {
  recipeSearchTerm: string;
  baseLiquorFilter: string;
  ingredientsByTag: { [tag: string]: Ingredient };
  favoritedRecipeIds: string[];
  filteredGroupedRecipes: GroupedRecipes[];
  ingredientSplitsByRecipeId: { [recipeId: string]: IngredientSplit };
}

interface DispatchProps {
  setRecipeSearchTerm: typeof setRecipeSearchTerm;
}

class RecipeListView extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  private _content: HTMLElement;
  private _searchBar: SearchBar;

  render() {
    return (
      <div className='recipe-list-view fixed-header-footer'>
        <RecipeListHeader />
        <div className='fixed-content-pane' ref={e => this._content = e}>
          <SearchBar
            className='list-topper'
            initialValue={this.props.recipeSearchTerm}
            placeholder='Name or ingredient...'
            onChange={this.props.setRecipeSearchTerm}
            ref={e => this._searchBar = e}
          />
          <RecipeList
            recipes={this.props.filteredGroupedRecipes}
            ingredientsByTag={this.props.ingredientsByTag}
            ingredientSplitsByRecipeId={this.props.ingredientSplitsByRecipeId}
            favoritedRecipeIds={this.props.favoritedRecipeIds}
          />
        </div>
      </div>
    );
  }

  componentDidMount() {
    this._attemptScrollDown = debounce(this._attemptScrollDown);
    this._attemptScrollDown();
  }

  componentDidUpdate(prevProps: ConnectedProps) {
    if (!this._searchBar.isFocused() && prevProps.baseLiquorFilter !== this.props.baseLiquorFilter) {
      this._attemptScrollDown();
    }
  }

  _attemptScrollDown = () => {
    this._content.scrollTop = RECIPE_LIST_ITEM_HEIGHT - RECIPE_LIST_HEADER_HEIGHT / 2;
  };
};

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    recipeSearchTerm: state.filters.recipeSearchTerm,
    baseLiquorFilter: state.filters.baseLiquorFilter,
    ingredientsByTag: state.ingredients.ingredientsByTag,
    favoritedRecipeIds: state.ui.favoritedRecipeIds,
    filteredGroupedRecipes: selectFilteredGroupedRecipes(state),
    ingredientSplitsByRecipeId: selectIngredientSplitsByRecipeId(state)
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({ setRecipeSearchTerm }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(RecipeListView) as React.ComponentClass<void>;

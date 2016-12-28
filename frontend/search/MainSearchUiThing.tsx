import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { RootState } from '../store';
import { Ingredient } from '../../shared/types';
import { GroupedRecipes } from '../types';
import { setSelectedIngredientTags } from '../store/atomicActions';
import { IngredientSplit } from '../store/derived/ingredientSplitsByRecipeId';
import { selectFilteredGroupedRecipes, selectIngredientSplitsByRecipeId } from '../store/selectors';
import TitleBar from '../components/TitleBar';
import Tabs from '../components/Tabs';
import IngredientsSidebar from '../recipes/IngredientsSidebar';
import RecipeList from '../recipes/RecipeList';

interface ConnectedProps {
  selectedIngredientTags: string[];
  ingredientsByTag: { [tag: string]: Ingredient };
  filteredGroupedRecipes: GroupedRecipes[];
  favoritedRecipeIds: string[];
  ingredientSplitsByRecipeId: { [recipeId: string]: IngredientSplit };
}

interface DispatchProps {
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
}

class MainSearchUiThing extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  render() {
    const drinkCount = this.props.filteredGroupedRecipes.reduce((acc, group) => acc + group.recipes.length, 0);
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
            name: `Drinks (${drinkCount})`
          }]}
        >
          <IngredientsSidebar
            onPendingTagsChange={this.props.setSelectedIngredientTags}
          />
          <RecipeList
            recipes={this.props.filteredGroupedRecipes}
            ingredientsByTag={this.props.ingredientsByTag}
            favoritedRecipeIds={this.props.favoritedRecipeIds}
            ingredientSplitsByRecipeId={this.props.ingredientSplitsByRecipeId}
          />
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
    ingredientsByTag: state.ingredients.ingredientsByTag,
    filteredGroupedRecipes: selectFilteredGroupedRecipes(state),
    favoritedRecipeIds: state.ui.favoritedRecipeIds,
    ingredientSplitsByRecipeId: selectIngredientSplitsByRecipeId(state)
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setSelectedIngredientTags
  }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(MainSearchUiThing) as React.ComponentClass<void>;

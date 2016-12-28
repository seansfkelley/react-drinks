import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { RootState } from '../store';
import { Ingredient } from '../../shared/types';
import { GroupedRecipes } from '../types';
import { setSelectedIngredientTags } from '../store/atomicActions';
import { selectFilteredGroupedRecipes } from '../store/selectors';
import TitleBar from '../components/TitleBar';
import Tabs from '../components/Tabs';
import IngredientsSidebar from '../recipes/IngredientsSidebar';
import RecipeList from '../recipes/RecipeList';

interface ConnectedProps {
  selectedIngredientTags: string[];
  ingredientsByTag: { [tag: string]: Ingredient };
  filteredGroupedRecipes: GroupedRecipes[];
}

interface DispatchProps {
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
}

class IterativeRecipeSearch extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  render() {
    const drinkCount = this.props.filteredGroupedRecipes.reduce((acc, group) => acc + group.recipes.length, 0);
    return (
      <div className='iterative-recipe-search'>
        <TitleBar
          leftIcon='fa-chevron-left'
          leftIconOnClick={this._popStack}
          className='dark'
        >
          <div className='lead-in'>Drinks with</div>
          <div className='ingredient-names'>
            {this.props.selectedIngredientTags.map(tag => (
              <span className='ingredient-name' key={tag}>{this.props.ingredientsByTag[tag].display}</span>
            ))}
          </div>
        </TitleBar>
        <Tabs
          tabs={[{
            name: `Ingredients (${this.props.selectedIngredientTags.length})`
          }, {
            name: `Drinks (${drinkCount})`
          }]}
          className='dark'
          initialTabIndex={1}
        >
          <IngredientsSidebar
            onPendingTagsChange={this.props.setSelectedIngredientTags}
          />
          <RecipeList
            recipes={this.props.filteredGroupedRecipes}
            ingredientsByTag={this.props.ingredientsByTag}
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
    filteredGroupedRecipes: selectFilteredGroupedRecipes(state)
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setSelectedIngredientTags
  }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(IterativeRecipeSearch) as React.ComponentClass<void>;

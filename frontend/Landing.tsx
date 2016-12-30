import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { RootState } from './store';
import {
  selectFilteredGroupedRecipes,
  selectFilteredGroupedIngredients,
  selectRecipeOfTheHour
} from './store/selectors';
import {
  setIngredientSearchTerm,
  setSelectedIngredientTags,
  showIngredientInfo
} from './store/atomicActions';
import { GroupedIngredients, GroupedRecipes } from './types';
import { Ingredient, Recipe } from '../shared/types';
import BlurOverlay from './components/BlurOverlay';
import TitleBar from './components/TitleBar';
import SearchBar from './components/SearchBar';
import RecipeView from './recipes/RecipeView';
import GroupedIngredientList from './ingredients/GroupedIngredientList';
import RecipeList from './recipes/RecipeList';
import PreviewRecipeListItem from './recipes/PreviewRecipeListItem';

interface ConnectedProps {
  recipesById: { [recipeId: string]: Recipe };
  randomRecipe: Recipe;
  ingredientSearchTerm: string;
  selectedIngredientTags: string[];
  ingredientsByTag: { [tag: string]: Ingredient };
  filteredGroupedIngredients: GroupedIngredients[];
  filteredGroupedRecipes: GroupedRecipes[];
}

interface DispatchProps {
  setIngredientSearchTerm: typeof setIngredientSearchTerm;
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
  showIngredientInfo: typeof showIngredientInfo;
}

class Landing extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  render() {
    return (
      <div className='landing'>
        {this._renderTitle()}
        <SearchBar
          onChange={this.props.setIngredientSearchTerm}
          value={this.props.ingredientSearchTerm}
          // TODO: Search recipes, their ingredients, and maybe even similar drinks here too!
          placeholder='Search for ingredients...'
          className='dark'
        />
        <BlurOverlay
          foreground={this.props.ingredientSearchTerm
            ? <GroupedIngredientList
                groupedIngredients={this.props.filteredGroupedIngredients}
                selectedIngredientTags={this.props.selectedIngredientTags}
                onSelectionChange={this._selectIngredient}
              />
            : null}
          background={this._renderBackground()}
          onBackdropClick={this._abortSearch}
        />
      </div>
    );
  }

  private _renderTitle() {
    if (this.props.selectedIngredientTags.length === 0) {
      return (
        <TitleBar className='default dark'>
          What can I get you?
        </TitleBar>
      );
    } else {
      return (
        <TitleBar
          leftIcon='fa-undo'
          leftIconOnClick={this._popStack}
          className='dark with-ingredients'
        >
          <div className='lead-in'>Drinks with</div>
          <div className='ingredient-names'>
            {this.props.selectedIngredientTags.map(tag => (
              <span className='ingredient-name' key={tag}>{this.props.ingredientsByTag[tag].display}</span>
            ))}
          </div>
        </TitleBar>
      );
    }
  }

  private _renderBackground() {
    if (this.props.selectedIngredientTags.length === 0) {
      return (
        <div className='random-cocktail'>
          <div className='random-cocktail-header'>Cocktail of the Hour</div>
          <RecipeView
            recipe={this.props.randomRecipe}
            availableIngredientTags={this.props.selectedIngredientTags}
            onIngredientTagsChange={this.props.setSelectedIngredientTags}
            onIngredientClick={this.props.showIngredientInfo}
          />
        </div>
      );
    } else {
      return (
        <RecipeList
          recipes={this.props.filteredGroupedRecipes}
          renderRecipe={this._renderRecipe}
        />
      );
    }
  }

  private _renderRecipe = (recipe: Recipe) => {
    return <PreviewRecipeListItem
      recipe={recipe}
      ingredientsByTag={this.props.ingredientsByTag}
      selectedIngredientTags={this.props.selectedIngredientTags}
    />;
  };

  private _popStack = () => {
    this.props.setSelectedIngredientTags(this.props.selectedIngredientTags.slice(0, this.props.selectedIngredientTags.length - 1));
  };

  private _selectIngredient = (tags: string[]) => {
    this.props.setIngredientSearchTerm('');
    this.props.setSelectedIngredientTags(tags);
  };

  private _abortSearch = () => {
    this.props.setIngredientSearchTerm('');
  };
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    recipesById: state.recipes.recipesById,
    randomRecipe: selectRecipeOfTheHour(state),
    ingredientSearchTerm: state.filters.ingredientSearchTerm,
    selectedIngredientTags: state.filters.selectedIngredientTags,
    ingredientsByTag: state.ingredients.ingredientsByTag,
    filteredGroupedIngredients: selectFilteredGroupedIngredients(state),
    filteredGroupedRecipes: selectFilteredGroupedRecipes(state)
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setIngredientSearchTerm,
    setSelectedIngredientTags,
    showIngredientInfo
   }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(Landing) as React.ComponentClass<void>;

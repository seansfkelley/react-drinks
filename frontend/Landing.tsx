import { without, flatten } from 'lodash';
import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { RootState } from './store';
import {
  selectFilteredGroupedRecipes,
  selectFuzzyMatchedIngredients,
  selectRecipeOfTheHour
} from './store/selectors';
import {
  setIngredientSearchTerm,
  setRecipeSearchTerm,
  setSelectedIngredientTags,
  showIngredientInfo
} from './store/atomicActions';
import { GroupedRecipes } from './types';
import { Ingredient, Recipe } from '../shared/types';
import BlurOverlay from './components/BlurOverlay';
import TitleBar from './components/TitleBar';
import SearchBar from './components/SearchBar';
import RecipeView from './recipes/RecipeView';
import PartialList from './components/PartialList';
import RecipeList from './recipes/RecipeList';
import PreviewRecipeListItem from './recipes/PreviewRecipeListItem';
import { List, ListItem, ListHeader } from './components/List';

interface FilteredIngredient {
  ingredient: Ingredient;
  bestMatch: {
    rendered: string;
    score: number;
  };
}

class IngredientPartialList extends PartialList<FilteredIngredient> {}
class RecipePartialList extends PartialList<Recipe> {}

interface ConnectedProps {
  recipesById: { [recipeId: string]: Recipe };
  randomRecipe: Recipe;
  ingredientSearchTerm: string;
  selectedIngredientTags: string[];
  ingredientsByTag: { [tag: string]: Ingredient };
  filteredIngredients: FilteredIngredient[];
  filteredGroupedRecipes: GroupedRecipes[];
}

interface DispatchProps {
  setIngredientSearchTerm: typeof setIngredientSearchTerm;
  setRecipeSearchTerm: typeof setRecipeSearchTerm;
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
  showIngredientInfo: typeof showIngredientInfo;
}

class Landing extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  render() {
    return (
      <div className='landing'>
        {this._renderTitle()}
        <SearchBar
          onChange={this._setAppropriateSearchTerms}
          value={this.props.ingredientSearchTerm}
          // TODO: Search recipes, their ingredients, and maybe even similar drinks here too!
          placeholder={this.props.selectedIngredientTags.length
            ? 'Add ingredients...'
            : 'Search recipes or ingredients...'}
          className='dark'
        />
        <BlurOverlay
          foreground={this._renderForeground()}
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

  private _renderForeground() {
    if (this.props.ingredientSearchTerm) {
      return (
        <List className='all-search-results-list'>
          {this.props.filteredIngredients.length
            ? <div>
                <ListHeader className='category-header'>Ingredients</ListHeader>
                <IngredientPartialList
                  className='ingredient-list'
                  items={this.props.filteredIngredients}
                  renderItem={this._renderFilteredIngredient}
                  softLimit={8}
                  hardLimit={12}
                />
              </div>
            : undefined}
          {this.props.filteredGroupedRecipes.length
            ? <div>
                <ListHeader className='category-header'>Recipes</ListHeader>
                <RecipePartialList
                  className='recipe-list'
                  items={flatten(this.props.filteredGroupedRecipes.map(g => g.recipes))}
                  renderItem={this._renderRecipe}
                />
              </div>
            : undefined}
        </List>
      );
    } else {
      return null;
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

  private _renderFilteredIngredient = (ingredient: FilteredIngredient) => {
    return (
      <ListItem
        key={ingredient.ingredient.tag}
        onClick={() => this._toggleIngredient(ingredient.ingredient.tag)}
        className='ingredient'
      >
        {ingredient.ingredient.display}
      </ListItem>
    );
  };

  private _renderRecipe = (recipe: Recipe) => {
    return (
      <PreviewRecipeListItem
        key={recipe.recipeId}
        recipe={recipe}
        ingredientsByTag={this.props.ingredientsByTag}
        selectedIngredientTags={this.props.selectedIngredientTags}
      />
    );
  };

  private _setAppropriateSearchTerms = (searchTerm: string) => {
    this.props.setIngredientSearchTerm(searchTerm);
    this.props.setRecipeSearchTerm(searchTerm);
  };

  private _popStack = () => {
    this.props.setSelectedIngredientTags(this.props.selectedIngredientTags.slice(0, this.props.selectedIngredientTags.length - 1));
  };

  private _toggleIngredient = (tag: string) => {
    this.props.setIngredientSearchTerm('');
    if (this.props.selectedIngredientTags.includes(tag)) {
      this.props.setSelectedIngredientTags(without(this.props.selectedIngredientTags, tag));
    } else {
      this.props.setSelectedIngredientTags(this.props.selectedIngredientTags.concat([ tag ]));
    }
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
    filteredIngredients: selectFuzzyMatchedIngredients(state),
    filteredGroupedRecipes: selectFilteredGroupedRecipes(state)
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setIngredientSearchTerm,
    setRecipeSearchTerm,
    setSelectedIngredientTags,
    showIngredientInfo
   }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(Landing) as React.ComponentClass<void>;

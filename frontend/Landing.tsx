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
  setSearchTerm,
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
  searchTerm: string;
  selectedIngredientTags: string[];
  ingredientsByTag: { [tag: string]: Ingredient };
  filteredIngredients: FilteredIngredient[];
  filteredGroupedRecipes: GroupedRecipes[];
}

interface DispatchProps {
  setSearchTerm: typeof setSearchTerm;
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
  showIngredientInfo: typeof showIngredientInfo;
}

class Landing extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  render() {
    return (
      <div className='landing'>
        {this._renderTitle()}
        {this._renderSearchBar()}
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

  private _renderSearchBar() {
    return (
      <SearchBar
        onChange={this.props.setSearchTerm}
        value={this.props.searchTerm}
        placeholder={this.props.selectedIngredientTags.length
          ? 'Add another ingredient...'
          : 'Search recipes or ingredients...'}
        className='dark'
      />
    );
  }

  private _renderForeground() {
    if (this.props.searchTerm) {
      return (
        <List
          className='all-search-results-list'
          emptyText='Nothing matched your search!'
        >
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
                  renderItem={this._makeRenderRecipe(false)}
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
          renderRecipe={this._makeRenderRecipe(true)}
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

  private _makeRenderRecipe = (includeTags: boolean) => (recipe: Recipe) => {
    return (
      <PreviewRecipeListItem
        key={recipe.recipeId}
        recipe={recipe}
        ingredientsByTag={this.props.ingredientsByTag}
        selectedIngredientTags={includeTags ? this.props.selectedIngredientTags : undefined}
      />
    );
  };

  private _popStack = () => {
    this.props.setSelectedIngredientTags(this.props.selectedIngredientTags.slice(0, this.props.selectedIngredientTags.length - 1));
  };

  private _toggleIngredient = (tag: string) => {
    this.props.setSearchTerm('');
    if (this.props.selectedIngredientTags.includes(tag)) {
      this.props.setSelectedIngredientTags(without(this.props.selectedIngredientTags, tag));
    } else {
      this.props.setSelectedIngredientTags(this.props.selectedIngredientTags.concat([ tag ]));
    }
  };

  private _abortSearch = () => {
    this.props.setSearchTerm('');
  };
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    recipesById: state.recipes.recipesById,
    randomRecipe: selectRecipeOfTheHour(state),
    searchTerm: state.filters.searchTerm,
    selectedIngredientTags: state.filters.selectedIngredientTags,
    ingredientsByTag: state.ingredients.ingredientsByTag,
    filteredIngredients: selectFuzzyMatchedIngredients(state),
    filteredGroupedRecipes: selectFilteredGroupedRecipes(state)
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setSearchTerm,
    setSelectedIngredientTags,
    showIngredientInfo
   }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(Landing) as React.ComponentClass<void>;

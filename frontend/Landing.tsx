import { without, flatten } from 'lodash';
import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { RootState } from './store';
import {
  FuzzyFilteredItem,
  selectSearchedRecipes,
  selectIngredientMatchedRecipes,
  selectSearchedIngredients,
  selectRecipeOfTheHour
} from './store/selectors';
import {
  setSearchTerm,
  setSelectedIngredientTags,
  showIngredientInfo,
  showRecipeViewer
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

class IngredientPartialList extends PartialList<FuzzyFilteredItem<Ingredient>> {}
class RecipePartialList extends PartialList<Recipe> {}

interface ConnectedProps {
  randomRecipe: Recipe;
  searchTerm: string;
  selectedIngredientTags: string[];
  ingredientsByTag: { [tag: string]: Ingredient };
  searchedIngredients: FuzzyFilteredItem<Ingredient>[];
  searchedRecipes: FuzzyFilteredItem<Recipe>[];
  ingredientMatchedRecipes: GroupedRecipes[];
}

interface DispatchProps {
  setSearchTerm: typeof setSearchTerm;
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
  showIngredientInfo: typeof showIngredientInfo;
  showRecipeViewer: typeof showRecipeViewer;
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
          {this.props.searchedIngredients.length
            ? <div>
                <ListHeader className='category-header'>Ingredients</ListHeader>
                <IngredientPartialList
                  className='ingredient-list'
                  items={this.props.searchedIngredients}
                  renderItem={this._renderFilteredIngredient}
                  softLimit={8}
                  hardLimit={12}
                />
              </div>
            : undefined}
          {this.props.searchedRecipes.length
            ? <div>
                <ListHeader className='category-header'>Recipes</ListHeader>
                <RecipePartialList
                  className='recipe-list'
                  items={this.props.searchedRecipes.map(r => r.item)}
                  renderItem={this._makeRenderRecipe(false, this.props.searchedRecipes.map(r => r.item.recipeId))}
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
          recipes={this.props.ingredientMatchedRecipes}
          renderRecipe={this._makeRenderRecipe(true, flatten(this.props.ingredientMatchedRecipes.map(g => g.recipes)).map(r => r.recipeId))}
        />
      );
    }
  }

  private _renderFilteredIngredient = (ingredient: FuzzyFilteredItem<Ingredient>) => {
    return (
      <ListItem
        key={ingredient.item.tag}
        onClick={() => this._toggleIngredient(ingredient.item.tag)}
        className='ingredient'
      >
        {ingredient.item.display}
      </ListItem>
    );
  };

  private _makeRenderRecipe = (includeTags: boolean, allRecipeIds: string[]) => (recipe: Recipe) => {
    return (
      <PreviewRecipeListItem
        key={recipe.recipeId}
        recipe={recipe}
        ingredientsByTag={this.props.ingredientsByTag}
        selectedIngredientTags={includeTags ? this.props.selectedIngredientTags : undefined}
        onClick={() => this.props.showRecipeViewer({ recipeIds: allRecipeIds, index: allRecipeIds.indexOf(recipe.recipeId) })}
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
    randomRecipe: selectRecipeOfTheHour(state),
    searchTerm: state.filters.searchTerm,
    selectedIngredientTags: state.filters.selectedIngredientTags,
    ingredientsByTag: state.ingredients.ingredientsByTag,
    searchedIngredients: selectSearchedIngredients(state),
    searchedRecipes: selectSearchedRecipes(state),
    ingredientMatchedRecipes: selectIngredientMatchedRecipes(state)
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setSearchTerm,
    setSelectedIngredientTags,
    showIngredientInfo,
    showRecipeViewer
   }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(Landing) as React.ComponentClass<void>;

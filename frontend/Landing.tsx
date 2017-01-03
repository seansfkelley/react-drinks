import { without, flatten } from 'lodash';
import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as classNames from 'classnames';

import { RootState } from './store';
import {
  FuzzyFilteredItem,
  selectSearchedRecipes,
  selectGroupedIngredientMatchedRecipes,
  selectSearchedIngredients,
  selectRecipeOfTheHour,
  selectAllTransitiveIngredientTags
} from './store/selectors';
import {
  setSearchTerm,
  setSelectedIngredientTags,
  showIngredientInfo,
  showRecipeViewer
} from './store/atomicActions';
import { BASIC_LIQUOR_TAGS } from '../shared/definitions';
import { GroupedItems } from './types';
import { Ingredient, Recipe } from '../shared/types';
import BlurOverlay from './components/BlurOverlay';
import TitleBar from './components/TitleBar';
import SearchBar from './components/SearchBar';
import PartialList from './components/PartialList';
import PreviewRecipeListItem from './recipes/PreviewRecipeListItem';
import IngredientListItem from './recipes/IngredientListItem';
import InteractiveRecipe from './recipes/InteractiveRecipe';
import { List, ListHeader, HeaderedList } from './components/List';

class BasicIngredientTagPartialList extends PartialList<string> {}
class FilteredIngredientPartialList extends PartialList<FuzzyFilteredItem<Ingredient>> {}
class RecipePartialList extends PartialList<Recipe> {}
class RecipeHeaderedList extends HeaderedList<Recipe> {}

interface ConnectedProps {
  randomRecipe: Recipe;
  searchTerm: string;
  selectedIngredientTags: string[];
  transitiveSelectedIngredientTags: string[];
  ingredientsByTag: { [tag: string]: Ingredient };
  searchedIngredients: FuzzyFilteredItem<Ingredient>[];
  searchedRecipes: FuzzyFilteredItem<Recipe>[];
  ingredientMatchedRecipes: GroupedItems<Recipe>[];
}

interface DispatchProps {
  setSearchTerm: typeof setSearchTerm;
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
  showIngredientInfo: typeof showIngredientInfo;
  showRecipeViewer: typeof showRecipeViewer;
}

interface State {
  forceDisplayResultList: boolean;
}

class Landing extends React.PureComponent<ConnectedProps & DispatchProps, State> {
  state: State = {
    forceDisplayResultList: false
  };

  render() {
    return (
      <div className='landing'>
        {this._renderTitle()}
        {this._renderSearchBar()}
        <BlurOverlay
          foreground={this._renderForeground()}
          background={this._renderBackground()}
          onBackdropClick={this._clearSearch}
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
          leftIcon='fa-chevron-left'
          leftIconOnClick={this._goHome}
          className='dark with-ingredients'
        >
          <div className='ingredient-names'>
            {this.props.selectedIngredientTags.map(tag => (
              <div className='ingredient-name' key={tag} onClick={() => this._removeTag(tag)}>
                {this.props.ingredientsByTag[tag].display}
                <i className='fa fa-times'/>
              </div>
            ))}
          </div>
        </TitleBar>
      );
    }
  }

  private _renderSearchBar() {
    return (
      <div className='search-bar-wrapper'>
        <SearchBar
          onChange={this.props.setSearchTerm}
          value={this.props.searchTerm}
          placeholder={this.props.selectedIngredientTags.length
            ? 'Add another ingredient...'
            : 'Search recipes or ingredients...'}
          className='dark'
          onFocusChange={this._setIsSearchBarFocused}
        />
        <div
          className={classNames('close-button', { 'is-visible': this._isShowingSearchResults() })}
          onClick={this._clearSearch}
        >
          Close
        </div>
      </div>
    );
  }

  private _setIsSearchBarFocused = (isFocused: boolean) => {
    if (isFocused) {
      this.setState({ forceDisplayResultList: true });
    }
  };

  private _isShowingSearchResults() {
    return !!(this.props.searchTerm || this.state.forceDisplayResultList);
  }

  private _renderForeground() {
    if (this._isShowingSearchResults()) {
      let content: React.ReactNode;

      if (this.props.searchTerm.trim().length === 0) {
        content = (
          <div>
              <ListHeader className='category-header'>Common Ingredients</ListHeader>
              <BasicIngredientTagPartialList
                className='ingredient-list'
                // HACKS: The render function uses state that isn't actually present on this
                // component, so it's not actually pure, so change the reference to force it...
                items={BASIC_LIQUOR_TAGS.slice()}
                renderItem={this._renderIngredientTag}
                softLimit={Infinity}
                hardLimit={Infinity}
              />
            </div>
        );
      } else {
        content = [
          this.props.searchedIngredients.length > 0
            ? <div key='ingredients'>
                <ListHeader className='category-header'>Ingredients</ListHeader>
                <FilteredIngredientPartialList
                  className='ingredient-list'
                  items={this.props.searchedIngredients}
                  renderItem={this._renderFilteredIngredient}
                  softLimit={8}
                  hardLimit={12}
                />
              </div>
            : undefined
        ,
          this.props.searchedRecipes.length > 0
            ? <div key='recipes'>
                <ListHeader className='category-header'>Recipes</ListHeader>
                <RecipePartialList
                  className='foreground-recipe-list'
                  items={this.props.searchedRecipes.map(r => r.item)}
                  renderItem={this._makeRenderRecipe(false, this.props.searchedRecipes.map(r => r.item.recipeId))}
                />
              </div>
            : undefined
        ];
      }

      return (
        <List
          className='all-search-results-list'
          emptyText='Nothing matched your search!'
        >
          {content}
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
          <InteractiveRecipe recipe={this.props.randomRecipe}/>
        </div>
      );
    } else {
      return (
        <RecipeHeaderedList
          className='background-recipe-list'
          groupedItems={this.props.ingredientMatchedRecipes}
          renderItem={this._makeRenderRecipe(true, flatten(this.props.ingredientMatchedRecipes.map(g => g.items)).map(r => r.recipeId))}
          renderHeader={this._renderListHeader}
        />
      );
    }
  }

  private _renderListHeader = (text: string) => {
    return <ListHeader
      className='thin-header'
      title={text.toUpperCase()}
      key={`header-${text}`}
    />;
  };

  private _renderFilteredIngredient = (ingredient: FuzzyFilteredItem<Ingredient>) => {
    return <IngredientListItem
      key={ingredient.item.tag}
      ingredient={ingredient.item}
      selectedIngredientTags={this.props.selectedIngredientTags}
      onClick={() => this._toggleIngredient(ingredient.item.tag)}
    />;
  };

  private _renderIngredientTag = (tag: string) => {
    const ingredient = this.props.ingredientsByTag[tag];

    if (ingredient) {
      return <IngredientListItem
        key={tag}
        ingredient={ingredient}
        selectedIngredientTags={this.props.selectedIngredientTags}
        onClick={() => this._toggleIngredient(tag)}
      />;
    } else {
      return null;
    }
  };

  private _makeRenderRecipe = (includeTags: boolean, allRecipeIds: string[]) => (recipe: Recipe) => {
    return (
      <PreviewRecipeListItem
        key={recipe.recipeId}
        recipe={recipe}
        ingredientsByTag={this.props.ingredientsByTag}
        selectedIngredientTags={includeTags ? this.props.transitiveSelectedIngredientTags : undefined}
        onClick={() => this.props.showRecipeViewer({ recipeIds: allRecipeIds, index: allRecipeIds.indexOf(recipe.recipeId) })}
      />
    );
  };

  private _goHome = () => {
    this.props.setSelectedIngredientTags([]);
  };

  private _removeTag = (tag: string) => {
    this.props.setSelectedIngredientTags(without(this.props.selectedIngredientTags, tag));
  };

  private _toggleIngredient = (tag: string) => {
    if (this.props.selectedIngredientTags.includes(tag)) {
      this.props.setSelectedIngredientTags(without(this.props.selectedIngredientTags, tag));
    } else {
      this.props.setSelectedIngredientTags(this.props.selectedIngredientTags.concat([ tag ]));
    }
    this._clearSearch();
  };

  private _clearSearch = () => {
    this.setState({ forceDisplayResultList: false });
    this.props.setSearchTerm('');
  };
}

function mapStateToProps(state: RootState): ConnectedProps {
  const { searchTerm, selectedIngredientTags } = state.filters;
  const isNonEmptySearch = searchTerm.trim().length > 0;
  return {
    searchTerm,
    selectedIngredientTags,
    randomRecipe: selectRecipeOfTheHour(state),
    transitiveSelectedIngredientTags: selectAllTransitiveIngredientTags(state),
    ingredientsByTag: state.ingredients.ingredientsByTag,
    searchedIngredients: isNonEmptySearch ? selectSearchedIngredients(state) : [],
    searchedRecipes: isNonEmptySearch && selectedIngredientTags.length === 0 ? selectSearchedRecipes(state) : [],
    ingredientMatchedRecipes: selectGroupedIngredientMatchedRecipes(state)
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

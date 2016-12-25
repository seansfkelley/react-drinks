import { debounce, flatten } from 'lodash';
import * as React from 'react';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import ReduxMixin from '../mixins/ReduxMixin';
import DerivedValueMixin from '../mixins/DerivedValueMixin';

import SearchBar from '../components/SearchBar';
import List from '../components/List';

import { Ingredient, Recipe } from '../../shared/types';
import { GroupedRecipes } from '../types';
import { IngredientSplit } from '../store/derived/ingredientSplitsByRecipeId';
import { store } from '../store';
import { RECIPE_LIST_ITEM_HEIGHT, RECIPE_LIST_HEADER_HEIGHT } from '../stylingConstants';
import { getHardest } from '../Difficulty';

import RecipeListItem from './RecipeListItem';
import RecipeListHeader from './RecipeListHeader';

interface RecipeListProps {
  recipes: GroupedRecipes[];
  ingredientsByTag: { [tag: string]: Ingredient };
  favoritedRecipeIds: string[];
  ingredientSplitsByRecipeId: { [recipeId: string]: IngredientSplit };
}

const RecipeList = React.createClass<RecipeListProps, void>({
  displayName: 'RecipeList',

  mixins: [PureRenderMixin],

  render() {
    const recipeCount = (this.props as RecipeListProps).recipes
      .map(rs => rs.recipes.length)
      .reduce((sum, l) => sum + l, 0);

    const listNodes = [];
    let absoluteIndex = 0;
    for (let { key, recipes } of this.props.recipes) {
      if (recipeCount > 6) {
        listNodes.push(this._makeHeader(key, recipes));
      }
      for (let r of recipes) {
        listNodes.push(this._makeItem(r, absoluteIndex));
        absoluteIndex += 1;
      }
    }

    return <List className={List.ClassNames.HEADERED}>{listNodes}</List>;
  },

  _makeHeader(groupKey: string) {
    return <List.Header title={groupKey.toUpperCase()} key={`header-${ groupKey }`} />;
  },

  _makeItem(recipe: Recipe, absoluteIndex: number) {
    let difficulty, isMixable;
    const missingIngredients = (this.props as RecipeListProps).ingredientSplitsByRecipeId[recipe.recipeId].missing;
    if (missingIngredients.length) {
      isMixable = false;
      difficulty = getHardest(missingIngredients.map(i => this.props.ingredientsByTag[i.tag!].difficulty));
    }

    return (
      <RecipeListItem
        difficulty={difficulty}
        isMixable={isMixable}
        recipeName={recipe.name}
        onClick={this._showRecipeViewer.bind(this, absoluteIndex)}
        onDelete={recipe.isCustom ? this._deleteRecipe.bind(null, recipe.recipeId) : undefined}
        key={recipe.recipeId}
      />
    );
  },

  _showRecipeViewer(index: number) {
    const recipeIds = flatten((this.props as RecipeListProps).recipes.map(group => group.recipes)).map(r => r.recipeId);

    store.dispatch({
      type: 'show-recipe-viewer',
      recipeIds,
      index
    });
  },

  _deleteRecipe(recipeId: string) {
    store.dispatch({
      type: 'delete-recipe',
      recipeId
    });
  }
});

interface State {
  recipeSearchTerm: string;
  baseLiquorFilter: string;
  ingredientsByTag: { [tag: string]: Ingredient };
  favoritedRecipeIds: string[];
  filteredGroupedRecipes: GroupedRecipes[];
  ingredientSplitsByRecipeId: { [recipeId: string]: IngredientSplit };
}

export default React.createClass<void, State>({
  displayName: 'RecipeListView',

  mixins: [
    ReduxMixin({
      filters: ['recipeSearchTerm', 'baseLiquorFilter'],
      ingredients: 'ingredientsByTag',
      ui: 'favoritedRecipeIds'
    }),
    DerivedValueMixin(['filteredGroupedRecipes', 'ingredientSplitsByRecipeId']),
    PureRenderMixin
  ],

  render() {
    return (
      <div className='recipe-list-view fixed-header-footer'>
        <RecipeListHeader />
        <div className='fixed-content-pane' ref='content'>
          <SearchBar
            className='list-topper'
            initialValue={this.state.recipeSearchTerm}
            placeholder='Name or ingredient...'
            onChange={this._onSearch}
            ref='search'
          />
          <RecipeList
            recipes={this.state.filteredGroupedRecipes}
            ingredientsByTag={this.state.ingredientsByTag}
            ingredientSplitsByRecipeId={this.state.ingredientSplitsByRecipeId}
            favoritedRecipeIds={this.state.favoritedRecipeIds}
          />
        </div>
      </div>
    );
  },

  componentDidMount() {
    this._attemptScrollDown();
  },

  componentDidUpdate(_prevProps: void, prevState: State) {
    if (!this.refs.search.isFocused() && prevState.baseLiquorFilter !== this.state.baseLiquorFilter) {
      this._attemptScrollDown();
    }
  },

  _attemptScrollDown: debounce(function () {
    this.refs.content.scrollTop = RECIPE_LIST_ITEM_HEIGHT - RECIPE_LIST_HEADER_HEIGHT / 2;
  }),

  _onSearch(searchTerm: string) {
    store.dispatch({
      type: 'set-recipe-search-term',
      searchTerm
    });
  }

});



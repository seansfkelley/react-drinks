
import * as React from 'react';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import ReduxMixin from '../mixins/ReduxMixin';
import DerivedValueMixin from '../mixins/DerivedValueMixin';

import Swipable from '../components/Swipable';

import { Ingredient, Recipe } from '../../shared/types';
import { IngredientSplit } from '../store/derived/ingredientSplitsByRecipeId';
import { store } from '../store';

import RecipeView from './RecipeView';

interface Props {
  onClose: Function;
}

interface State {
  recipesById: { [recipeId: string]: Recipe };
  ingredientsByTag: { [tag: string]: Ingredient };
  favoritedRecipeIds: string[];
  currentlyViewedRecipeIds: string[];
  recipeViewingIndex: number;
  ingredientSplitsByRecipeId: { [recipeId: string]: IngredientSplit };
}

export default React.createClass<Props, State>({
  displayName: 'SwipableRecipeView',

  propTypes: {
    onClose: React.PropTypes.func.isRequired
  },

  mixins: [
    ReduxMixin({
      recipes: 'recipesById',
      ingredients: 'ingredientsByTag',
      ui: ['favoritedRecipeIds', 'currentlyViewedRecipeIds', 'recipeViewingIndex']
    }),
    DerivedValueMixin(['ingredientSplitsByRecipeId']),
    PureRenderMixin
  ],

  render() {
    if (this.state.currentlyViewedRecipeIds.length === 0) {
      return <div />;
    } else {
      const recipePages = (this.state as State).currentlyViewedRecipeIds.map((recipeId, i) => {
        return (
          <div className='swipable-padding-wrapper' key={recipeId}>
            {Math.abs(i - this.state.recipeViewingIndex) <= 1
              ? this._renderRecipe(this.state.recipesById[recipeId])
              : undefined}
          </div>
        );
      });

      return (
        <Swipable
          className='swipable-recipe-container'
          initialIndex={this.state.recipeViewingIndex}
          onSlideChange={this._onSlideChange}
          friction={0.9}
        >
          {recipePages}
        </Swipable>
      );
    }
  },

  _renderRecipe(recipe: Recipe) {
    return (
      <div className='swipable-position-wrapper'>
        <RecipeView
          recipe={recipe}
          ingredientsByTag={this.state.ingredientsByTag}
          ingredientSplits={this.state.ingredientSplitsByRecipeId ? this.state.ingredientSplitsByRecipeId[recipe.recipeId] : undefined}
          onClose={this._onClose}
          onFavorite={this._onFavorite}
          onEdit={recipe.isCustom ? this._onEdit : undefined}
          isFavorited={this.state.favoritedRecipeIds.includes(recipe.recipeId)}
          isShareable={true}
        />
      </div>
    );
  },

  _onSlideChange(index: number) {
    store.dispatch({
      type: 'set-recipe-viewing-index',
      index
    });
  },

  _onClose() {
    store.dispatch({
      type: 'set-recipe-viewing-index',
      index: 0
    });

    this.props.onClose();
  },

  _onEdit(recipe: Recipe) {
    store.dispatch({
      type: 'seed-recipe-editor',
      recipe
    });

    store.dispatch({
      type: 'show-recipe-editor'
    });
  },

  _onFavorite(recipe: Recipe, shouldFavorite: boolean) {
    if (shouldFavorite) {
      store.dispatch({
        type: 'favorite-recipe',
        recipeId: recipe.recipeId
      });
    } else {
      store.dispatch({
        type: 'unfavorite-recipe',
        recipeId: recipe.recipeId
      });
    }
  }
});

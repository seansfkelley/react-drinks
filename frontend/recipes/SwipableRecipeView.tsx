
import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import Swipable from '../components/Swipable';

import { Ingredient, Recipe } from '../../shared/types';
import { IngredientSplit } from '../store/derived/ingredientSplitsByRecipeId';
import { RootState } from '../store';
import { selectIngredientSplitsByRecipeId } from '../store/selectors';
import {
  setRecipeViewingIndex,
  seedRecipeEditor,
  showRecipeEditor,
  favoriteRecipe,
  unfavoriteRecipe,
  hideRecipeViewer,
  setSelectedIngredientTags
} from '../store/atomicActions';

import RecipeView from './RecipeView';

interface ConnectedProps {
  recipesById: { [recipeId: string]: Recipe };
  ingredientsByTag: { [tag: string]: Ingredient };
  favoritedRecipeIds: string[];
  currentlyViewedRecipeIds: string[];
  recipeViewingIndex: number;
  ingredientSplitsByRecipeId: { [recipeId: string]: IngredientSplit };
  selectedIngredientTags: string[];
}

interface DispatchProps {
  setRecipeViewingIndex: typeof setRecipeViewingIndex;
  seedRecipeEditor: typeof seedRecipeEditor;
  showRecipeEditor: typeof showRecipeEditor;
  favoriteRecipe: typeof favoriteRecipe;
  unfavoriteRecipe: typeof unfavoriteRecipe;
  hideRecipeViewer: typeof hideRecipeViewer;
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
}

class SwipableRecipeView extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  render() {
    if (this.props.currentlyViewedRecipeIds.length === 0) {
      return <div />;
    } else {
      const recipePages = this.props.currentlyViewedRecipeIds.map((recipeId, i) => {
        return (
          <div className='swipable-padding-wrapper' key={recipeId}>
            {Math.abs(i - this.props.recipeViewingIndex) <= 1
              ? this._renderRecipe(this.props.recipesById[recipeId])
              : undefined}
          </div>
        );
      });

      return (
        <Swipable
          className='swipable-recipe-container'
          initialIndex={this.props.recipeViewingIndex}
          onSlideChange={this.props.setRecipeViewingIndex}
          friction={0.9}
        >
          {recipePages}
        </Swipable>
      );
    }
  }

  _renderRecipe(recipe: Recipe) {
    return (
      <div className='swipable-position-wrapper'>
        <RecipeView
          recipe={recipe}
          availableIngredientTags={this.props.selectedIngredientTags}
          onIngredientTagsChange={this._onIngredientTagsChange}
          onClose={this._onClose}
          onFavorite={this._onFavorite}
          onEdit={recipe.isCustom ? this._onEdit : undefined}
          isFavorited={this.props.favoritedRecipeIds.includes(recipe.recipeId)}
          isShareable={true}
        />
      </div>
    );
  }

  private _onClose = () => {
    this.props.setRecipeViewingIndex(0);
    this.props.hideRecipeViewer();
  };

  private _onEdit = (recipe: Recipe) => {
    this.props.seedRecipeEditor(recipe);
    this.props.showRecipeEditor();
  };

  private _onFavorite = (recipe: Recipe, shouldFavorite: boolean) => {
    if (shouldFavorite) {
      this.props.favoriteRecipe(recipe.recipeId);
    } else {
      this.props.unfavoriteRecipe(recipe.recipeId);
    }
  };

  private _onIngredientTagsChange = (tags: string[]) => {
    this.props.setSelectedIngredientTags(tags);
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setRecipeViewingIndex,
    seedRecipeEditor,
    showRecipeEditor,
    favoriteRecipe,
    unfavoriteRecipe,
    hideRecipeViewer,
    setSelectedIngredientTags
  }, dispatch);
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    recipesById: state.recipes.recipesById,
    ingredientsByTag: state.ingredients.ingredientsByTag,
    favoritedRecipeIds: state.ui.favoritedRecipeIds,
    currentlyViewedRecipeIds: state.ui.currentlyViewedRecipeIds,
    recipeViewingIndex: state.ui.recipeViewingIndex,
    ingredientSplitsByRecipeId: selectIngredientSplitsByRecipeId(state),
    selectedIngredientTags: state.filters.selectedIngredientTags
  };
}

export default connect(mapStateToProps, mapDispatchToProps)(SwipableRecipeView) as React.ComponentClass<void>;

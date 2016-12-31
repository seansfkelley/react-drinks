
import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import Swipable from '../components/Swipable';

import { Ingredient, Recipe } from '../../shared/types';
import { IngredientSplit } from '../store/derived/ingredientSplitsByRecipeId';
import { RootState } from '../store';
import {
  selectIngredientSplitsByRecipeId,
  selectSimilarRecipesByRecipeId
} from '../store/selectors';
import {
  setRecipeViewingIndex,
  seedRecipeEditor,
  showRecipeEditor,
  favoriteRecipe,
  unfavoriteRecipe,
  hideRecipeViewer,
  setSelectedIngredientTags,
  showIngredientInfo,
  showRecipeViewer
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
  similarRecipesById: { [recipeId: string]: Recipe[] };
}

interface DispatchProps {
  setRecipeViewingIndex: typeof setRecipeViewingIndex;
  seedRecipeEditor: typeof seedRecipeEditor;
  showRecipeEditor: typeof showRecipeEditor;
  favoriteRecipe: typeof favoriteRecipe;
  unfavoriteRecipe: typeof unfavoriteRecipe;
  hideRecipeViewer: typeof hideRecipeViewer;
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
  showIngredientInfo: typeof showIngredientInfo;
  showRecipeViewer: typeof showRecipeViewer;
}

class SwipableRecipeView extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  private _swipable: Swipable;

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
          onIndexChange={this.props.setRecipeViewingIndex}
          friction={0.9}
          ref={e => this._swipable = e}
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
          onIngredientClick={this.props.showIngredientInfo}
          similarRecipes={this.props.similarRecipesById[recipe.recipeId]}
          onSimilarRecipeClick={this._replaceWithRecipeId}
          onClose={this._onClose}
          onFavorite={this._onFavorite}
          onEdit={recipe.isCustom ? this._onEdit : undefined}
          isFavorited={this.props.favoritedRecipeIds.includes(recipe.recipeId)}
          isShareable={true}
        />
      </div>
    );
  }

  componentWillReceiveProps(nextProps: ConnectedProps) {
    if (this._swipable && nextProps.recipeViewingIndex !== this.props.recipeViewingIndex) {
      this._swipable.setIndexToIfNecessary(nextProps.recipeViewingIndex);
    }
  }

  private _replaceWithRecipeId = (recipeId: string) => {
    this.props.showRecipeViewer({ recipeIds: [ recipeId ], index: 0 });
  };

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
    setSelectedIngredientTags,
    showIngredientInfo,
    showRecipeViewer
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
    selectedIngredientTags: state.filters.selectedIngredientTags,
    similarRecipesById: selectSimilarRecipesByRecipeId(state)
  };
}

export default connect(mapStateToProps, mapDispatchToProps)(SwipableRecipeView) as React.ComponentClass<void>;

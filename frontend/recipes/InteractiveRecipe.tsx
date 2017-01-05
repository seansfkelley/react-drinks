import { without } from 'lodash';
import * as React from 'react';
import * as classNames from 'classnames';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { Ingredient, Recipe, DisplayIngredient } from '../../shared/types';
import { BASE_URL } from '../../shared/constants';
import { RootState } from '../store';
import TitleBar from '../components/TitleBar';
import { List, ListHeader } from '../components/List';
import PreviewRecipeListItem from './PreviewRecipeListItem';
import MeasuredIngredient from './MeasuredIngredient';
import RecipeBody from './RecipeBody';

import {
  showIngredientInfo,
  setRecipeFavorite,
  setSelectedIngredientTags
} from '../store/atomicActions';
import {
  selectSimilarRecipesByRecipeId,
  selectAllTransitiveIngredientTags
} from '../store/selectors';

function IconButton(props: { icon: string, text: string, onClick?: React.MouseEventHandler<HTMLElement> }) {
  return (
    <div className='icon-button' onClick={props.onClick}>
      <i className={classNames('fa', props.icon)} />
      <div className='label'>{props.text}</div>
    </div>
  );
}

interface OwnProps {
  recipe: Recipe;
  onClose?: () => void;
  onSimilarRecipeClick?: (recipeId: string) => void;
  showFavoriteButton?: boolean;
  showShareButton?: boolean;
  showSimilarRecipes?: boolean;
}

interface ConnectedProps {
  selectedIngredientTags: string[];
  transitiveSelectedIngredientTags: string[];
  ingredientsByTag: { [tag: string]: Ingredient };
  similarRecipes: Recipe[];
  isFavorited: boolean;
}

interface DispatchProps {
  setRecipeFavorite: typeof setRecipeFavorite;
  showIngredientInfo: typeof showIngredientInfo;
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
}

class InteractiveRecipe extends React.PureComponent<OwnProps & ConnectedProps & DispatchProps, void> {
  render() {
    let header;
    if (this.props.onClose != null) {
      header = (
        <TitleBar className='fixed-header' rightIcon='fa-times' rightIconOnClick={this.props.onClose}>
          {this.props.recipe.name}
        </TitleBar>
      );
    } else {
      header = <TitleBar className='fixed-header'>{this.props.recipe.name}</TitleBar>;
    }

    let similarRecipes;
    if (this.props.showSimilarRecipes && this.props.similarRecipes && this.props.similarRecipes.length) {
      similarRecipes = (
        <List className='similar-recipes-list'>
          <ListHeader>Similar Drinks</ListHeader>
          {this.props.similarRecipes.map(recipe =>
            <PreviewRecipeListItem
              key={recipe.recipeId}
              recipe={recipe}
              ingredientsByTag={this.props.ingredientsByTag}
              onClick={this.props.onSimilarRecipeClick ? () => this.props.onSimilarRecipeClick!(recipe.recipeId) : undefined}
            />
          )}
        </List>
      );
    }

    const footerButtons = [];

    if (this.props.showShareButton) {
      footerButtons.push(
        <IconButton
          key='share'
          icon='fa-share-square-o'
          text='Share'
          onClick={this._shareRecipe}
        />
      );
    }
    if (this.props.showFavoriteButton) {
      footerButtons.push(
        <IconButton
          key='favorite'
          icon={classNames({ 'fa-star': this.props.isFavorited, 'fa-star-o': !this.props.isFavorited })}
          text='Favorite'
          onClick={this._onFavorite}
        />
      );
    }

    return (
      <div className='interactive-recipe fixed-header-footer'>
        {header}
        <div className='fixed-content-pane'>
          <RecipeBody
            recipe={this.props.recipe}
            renderIngredient={this._renderIngredient}
          />
        {similarRecipes}
        </div>
        {footerButtons.length ? <div className='footer-buttons fixed-footer'>{footerButtons}</div> : undefined}
      </div>
    );
  }

  private _renderIngredient = (ingredient: DisplayIngredient) => {
    return (
      <MeasuredIngredient
        ingredient={ingredient}
        isSelected={this.props.selectedIngredientTags.includes(ingredient.tag)}
        onSelectionChange={this._onIngredientToggle}
        onClick={this.props.showIngredientInfo}
      />
    );
  };

  private _shareRecipe = () => {
    window.open(`sms:&body=${this.props.recipe.name} ${BASE_URL}/recipe/${this.props.recipe.recipeId}`)
  };

  private _onFavorite = () => {
    this.props.setRecipeFavorite({
      recipeId: this.props.recipe.recipeId,
      isFavorite: !this.props.isFavorited
    });
  };

  private _onIngredientToggle = (tag: string) => {
    if (this.props.selectedIngredientTags.includes(tag)) {
      this.props.setSelectedIngredientTags(without(this.props.selectedIngredientTags, tag));
    } else {
      this.props.setSelectedIngredientTags(this.props.selectedIngredientTags.concat([ tag ]));
    }
  };
}

function mapStateToProps(state: RootState, ownProps: OwnProps): ConnectedProps {
  return {
    selectedIngredientTags: state.filters.selectedIngredientTags,
    transitiveSelectedIngredientTags: selectAllTransitiveIngredientTags(state),
    ingredientsByTag: state.ingredients.ingredientsByTag,
    similarRecipes: selectSimilarRecipesByRecipeId(state)[ownProps.recipe.recipeId],
    isFavorited: state.ui.favoritedRecipeIds.includes(ownProps.recipe.recipeId)
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setRecipeFavorite,
    showIngredientInfo,
    setSelectedIngredientTags
   }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(InteractiveRecipe) as React.ComponentClass<OwnProps>;

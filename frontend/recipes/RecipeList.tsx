import { flatten } from 'lodash';
import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { List, ListHeader, ListClassNames } from '../components/List';

import { Ingredient, Recipe } from '../../shared/types';
import { GroupedRecipes } from '../types';
import { IngredientSplit } from '../store/derived/ingredientSplitsByRecipeId';
import { RootState } from '../store';
import { showRecipeViewer, deleteRecipe } from '../store/atomicActions';
import { getHardest } from '../Difficulty';

import RecipeListItem from './RecipeListItem';

interface OwnProps {
  recipes: GroupedRecipes[];
  ingredientsByTag: { [tag: string]: Ingredient };
  favoritedRecipeIds: string[];
  ingredientSplitsByRecipeId: { [recipeId: string]: IngredientSplit };
}

interface DispatchProps {
  showRecipeViewer: typeof showRecipeViewer;
  deleteRecipe: typeof deleteRecipe;
}

class RecipeList extends React.PureComponent<OwnProps & DispatchProps, void> {
  render() {
    const recipeCount = this.props.recipes
      .map(rs => rs.recipes.length)
      .reduce((sum, l) => sum + l, 0);

    const listNodes = [];
    let absoluteIndex = 0;
    for (let { key, recipes } of this.props.recipes) {
      if (recipeCount > 6) {
        listNodes.push(this._makeHeader(key));
      }
      for (let r of recipes) {
        listNodes.push(this._makeItem(r, absoluteIndex));
        absoluteIndex += 1;
      }
    }

    return <List className={ListClassNames.HEADERED}>{listNodes}</List>;
  }

  _makeHeader(groupKey: string) {
    return <ListHeader title={groupKey.toUpperCase()} key={`header-${ groupKey }`} />;
  }

  _makeItem(recipe: Recipe, absoluteIndex: number) {
    let difficulty, isMixable;
    const missingIngredients = this.props.ingredientSplitsByRecipeId[recipe.recipeId].missing;
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
        onDelete={recipe.isCustom ? this.props.deleteRecipe.bind(null, recipe.recipeId) : undefined}
        key={recipe.recipeId}
      />
    );
  }

  _showRecipeViewer(index: number) {
    const recipeIds = flatten(this.props.recipes.map(group => group.recipes)).map(r => r.recipeId);
    this.props.showRecipeViewer(recipeIds, index);
  }
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    showRecipeViewer,
    deleteRecipe
  }, dispatch);
}

export default connect(null as any, mapDispatchToProps)(RecipeList) as React.ComponentClass<OwnProps>;

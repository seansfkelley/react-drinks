import * as React from 'react';
import * as classNames from 'classnames';

import { Ingredient, Recipe } from '../../shared/types';
import { ListItem, DeletableListItem } from '../components/List';
import { IngredientSplit } from '../store/derived/ingredientSplitsByRecipeId';
import { getHardest, CLASS_NAME, HUMAN_READABLE } from '../Difficulty';

interface Props {
  recipe: Recipe;
  ingredientSplitsByRecipeId: { [recipeId: string]: IngredientSplit };
  ingredientsByTag: { [tag: string]: Ingredient };
  onClick?: () => void;
  onDelete?: Function;
}

export default class DefaultRecipeListItem extends React.PureComponent<Props, void> {
  render() {
    let isMixable = true;
    let difficulty;
    const missingIngredients = this.props.ingredientSplitsByRecipeId[this.props.recipe.recipeId].missing;
    if (missingIngredients.length) {
      isMixable = false;
      difficulty = getHardest(missingIngredients.map(i => this.props.ingredientsByTag![i.tag!].difficulty));
    }

    const difficultyNode = difficulty
      ? <span className={classNames('difficulty', CLASS_NAME[difficulty])} key='difficulty'>
          {HUMAN_READABLE[difficulty]}
        </span>
      : undefined;
    const content = [ <span className='name' key='name'>{this.props.recipe.name}</span>, difficultyNode ];
    const className = classNames('recipe-list-item default-recipe-list-item', { 'is-mixable': isMixable });
    return this.props.onDelete
      ? <DeletableListItem className={className} onClick={this.props.onClick} onDelete={this.props.onDelete}>{content}</DeletableListItem>
      : <ListItem className={className} onClick={this.props.onClick}>{content}</ListItem>;
  }
}

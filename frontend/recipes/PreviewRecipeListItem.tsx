import { groupBy, uniq } from 'lodash';
import * as React from 'react';
import * as classNames from 'classnames';

import { Ingredient, Recipe } from '../../shared/types';
import { ListItem } from '../components/List';

interface Props {
  recipe: Recipe;
  ingredientsByTag: { [tag: string]: Ingredient };
  selectedIngredientTags?: string[];
  onClick?: () => void;
}

export default class PreviewRecipeListItem extends React.PureComponent<Props, void> {
  render() {
    const uniqueIngredientTags = uniq(
      this.props.recipe.ingredients
        .map(i => i.tag)
        .filter(t => !!t) as string[]
    );
    let ingredients;
    if (this.props.selectedIngredientTags) {
      let {
        true: includedIngredients,
        false: missingIngredients
      } = groupBy(uniqueIngredientTags, t => this.props.selectedIngredientTags!.includes(t));

      ingredients = ([] as React.ReactNode[])
        .concat((missingIngredients || []).map(this._makeRenderTag('missing')))
        .concat((includedIngredients || []).map(this._makeRenderTag('available')));
    } else {
      ingredients = uniqueIngredientTags.map(this._makeRenderTag());
    }

    return (
      <ListItem className='preview-recipe-list-item recipe-list-item' onClick={this.props.onClick}>
        <div className='name'>{this.props.recipe.name}</div>
        <div className='ingredient-list'>
          {ingredients}
        </div>
      </ListItem>
    );
  }

  private _makeRenderTag(className?: string) {
    return (t: string) => (
      <span className={classNames('ingredient', className)} key={t}>
        {this.props.ingredientsByTag[t].display}
      </span>
    );
  }
}

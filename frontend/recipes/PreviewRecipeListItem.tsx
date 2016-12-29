import { groupBy, uniq } from 'lodash';
import * as React from 'react';

import { Ingredient, Recipe } from '../../shared/types';
import { ListItem } from '../components/List';

interface Props {
  recipe: Recipe;
  ingredientsByTag: { [tag: string]: Ingredient };
  selectedIngredientTags: string[];
  onClick?: () => void;
}

export default class extends React.PureComponent<Props, void> {
  render() {
    // TODO: This isn't quite right -- it doesn't do generics and all that jazz. But close enough for a demonstration.
    const {
      true: includedIngredients,
      false: missingIngredients
    } = groupBy(
      uniq(
        this.props.recipe.ingredients
          .map(i => i.tag)
          .filter(t => !!t) as string[]
      ),
      t => this.props.selectedIngredientTags.includes(t)
    );

    return (
      <ListItem className='preview-recipe-list-item recipe-list-item' onClick={this.props.onClick}>
        <div className='name'>{this.props.recipe.name}</div>
        <div className='ingredient-list'>
          {missingIngredients.map(t => (
            <span className='ingredient missing' key={t}>
              {this.props.ingredientsByTag[t].display}
            </span>
          ))}
          {includedIngredients.map(t => (
            <span className='ingredient available' key={t}>
              {this.props.ingredientsByTag[t].display}
            </span>
          ))}
        </div>
      </ListItem>
    );
  }
}



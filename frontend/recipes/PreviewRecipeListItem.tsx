import { groupBy } from 'lodash';
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
    } = groupBy(this.props.recipe.ingredients.filter(i => !!i.tag), i => this.props.selectedIngredientTags.includes(i.tag));

    return (
      <ListItem className='preview-recipe-list-item recipe-list-item' onClick={this.props.onClick}>
        <div className='name'>{this.props.recipe.name}</div>
        <div className='ingredient-list'>
          {missingIngredients.map(i => (
            <span className='ingredient missing' key={i.tag}>
              {this.props.ingredientsByTag[i.tag!].display}
            </span>
          ))}
          {includedIngredients.map(i => (
            <span className='ingredient available' key={i.tag}>
              {this.props.ingredientsByTag[i.tag!].display}
            </span>
          ))}
        </div>
      </ListItem>
    );
  }
}



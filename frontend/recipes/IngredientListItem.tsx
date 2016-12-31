import * as React from 'react';
import * as classNames from 'classnames';

import { Ingredient } from '../../shared/types';
import { ListItem } from '../components/List';

interface Props {
  ingredient: Ingredient;
  onClick: () => void;
  selectedIngredientTags?: string[];
}

export default class IngredientListItem extends React.PureComponent<Props, void> {
  render() {
    return (
      <ListItem
        className={classNames('ingredient-list-item', {
          'is-selected': this.props.selectedIngredientTags && this.props.selectedIngredientTags.includes(this.props.ingredient.tag)
        })}
        onClick={this.props.onClick}
      >
        {this.props.ingredient.display}
      </ListItem>
    );
  }
}

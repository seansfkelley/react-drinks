import * as React from 'react';

import { fractionify } from '../utils';
import { Recipe, DisplayIngredient } from '../../shared/types';

import MeasuredIngredient from './MeasuredIngredient';

interface Props {
  recipe: Recipe;
  renderIngredient?: (ingredient: DisplayIngredient) => React.ReactElement<any>;
}

function defaultRenderIngredient(ingredient: DisplayIngredient) {
  return <MeasuredIngredient ingredient={ingredient}/>;
}

export default class RecipeBody extends React.PureComponent<Props, void> {
  static defaultProps = {
    renderIngredient: defaultRenderIngredient
  };

  render() {
    const ingredients = this.props.recipe.ingredients
      .map(this.props.renderIngredient!)
      .map((node, i) => React.cloneElement(node, { key: i}));

    let notes;
    if (this.props.recipe.notes != null) {
      notes = (
        <div className='recipe-notes'>
          <div className='text'>{fractionify(this.props.recipe.notes)}</div>
        </div>
      );
    }

    let url;
    if (this.props.recipe.source != null && this.props.recipe.url != null) {
      url = (
        <a className='recipe-url' href={this.props.recipe.url} target='_blank'>
          <span className='lead-in'>source:</span>
          {this.props.recipe.source}
          <i className='fa fa-external-link' />
        </a>
      );
    }

    const instructions = (
      <ol className='recipe-instructions'>
        {this.props.recipe.instructions.split('\n')
          .map(l => l.trim())
          .filter(l => l.length > 0)
          .map((l, i) => (
            <li className='text-line' key={i}>{fractionify(l)}</li>
          ))}
      </ol>
    );

    return (
      <div className='recipe-body'>
        <div className='recipe-ingredients'>
          {ingredients}
        </div>
        {instructions}
        {notes}
        {url}
      </div>
    );
  }
}

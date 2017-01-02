import * as React from 'react';

import { Recipe } from '../../../shared/types';
import { BASE_URL } from '../../../shared/definitions';
import TitleBar from '../../components/TitleBar';
import RecipeBody from '../../recipes/RecipeBody';

interface Props {
  recipe: Recipe;
}

export default class StandaloneRecipe extends React.PureComponent<Props, void> {
  render() {
    return (
      <div className='standalone-recipe'>
        <a className='homepage-link' href={BASE_URL} target='_blank'>
          <TitleBar>
            Spirit Guide
            <i className='fa fa-chevron-right' />
          </TitleBar>
        </a>
        <TitleBar className='recipe-name'>{this.props.recipe.name}</TitleBar>
        <RecipeBody recipe={this.props.recipe} />
      </div>
    );
  }
}

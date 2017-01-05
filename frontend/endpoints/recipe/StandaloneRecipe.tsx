import * as React from 'react';

import { Recipe } from '../../../shared/types';
import { BASE_URL, APP_NAME } from '../../../shared/constants';
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
            {APP_NAME}
            <i className='fa fa-chevron-right' />
          </TitleBar>
        </a>
        <TitleBar className='recipe-name'>{this.props.recipe.name}</TitleBar>
        <RecipeBody recipe={this.props.recipe} />
      </div>
    );
  }
}

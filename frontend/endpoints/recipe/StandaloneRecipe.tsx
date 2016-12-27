import * as React from 'react';

import { Recipe } from '../../../shared/types';
import { BASE_URL } from '../../../shared/definitions';
import TitleBar from '../../components/TitleBar';
import RecipeView from '../../recipes/RecipeView';

interface Props {
  recipe: Recipe;
}

export default class extends React.PureComponent<Props, void> {
  render() {
    return (
      <div className='standalone-recipe'>
        <a className='homepage-link' href={BASE_URL} target='_blank'>
          <TitleBar>
            Spirit Guide
            <i className='fa fa-chevron-right' />
          </TitleBar>
        </a>
        <RecipeView recipe={this.props.recipe} />
      </div>
    );
  }
}

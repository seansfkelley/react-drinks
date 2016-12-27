import { defaults, flatten } from 'lodash';
import * as React from 'react';
import * as classNames from 'classnames';

import { fractionify } from '../utils';
import { assert } from '../../shared/tinyassert';
import { Ingredient, Recipe, DisplayIngredient } from '../../shared/types';
import { IngredientSplit, SubstituteDisplayIngredient } from '../store/derived/ingredientSplitsByRecipeId';
import { BASE_URL } from '../../shared/definitions';

import TitleBar from '../components/TitleBar';

import MeasuredIngredient, { Props as MeasuredIngredientProps } from './MeasuredIngredient';

type IngredientCategory = 'missing' | 'substitute' | 'available';
const IngredientCategory = {
  MISSING: 'missing' as IngredientCategory,
  SUBSTITUTE: 'substitute' as IngredientCategory,
  AVAILABLE: 'available' as IngredientCategory
};

const ORDERED_CATEGORIES = [IngredientCategory.MISSING, IngredientCategory.SUBSTITUTE, IngredientCategory.AVAILABLE];

function IconButton(props: { icon: string, text: string, onClick?: React.MouseEventHandler<HTMLElement> }) {
  return (
    <div className='icon-button' onClick={props.onClick}>
      <i className={classNames('fa', props.icon)} />
      <div className='label'>{props.text}</div>
    </div>
  );
}

interface Props {
  recipe: Recipe;
  ingredientSplits?: IngredientSplit;
  ingredientsByTag?: { [tag: string]: Ingredient };
  onClose?: () => void;
  onFavorite?: (recipe: Recipe, isFavorited: boolean) => void;
  onEdit?: (recipe: Recipe) => void;
  isFavorited?: boolean;
  isShareable?: boolean;
}

export default class extends React.PureComponent<Props, void> {
  static defaultProps = {
    isShareable: false
  };

  render() {
    let ingredients;
    if (this.props.ingredientSplits != null && this.props.ingredientsByTag != null) {
      ingredients = flatten(ORDERED_CATEGORIES.map(category => this._renderCategory(this.props.ingredientSplits![category], category)));
    } else {
      ingredients = this.props.recipe.ingredients.map((i: DisplayIngredient) =>
        // This fucked-up key is because sometimes, the same tag will appear twice (e.g. Penicillin's two scotches).
        <MeasuredIngredient {...i} key={`${ i.tag } ${ i.displayIngredient }`}/>
      );
    }

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
        {(this.props as Props).recipe.instructions.split('\n')
          .map(l => l.trim())
          .filter(l => l.length > 0)
          .map((l, i) => (
            <li className='text-line' key={i}>{fractionify(l)}</li>
          ))}
      </ol>
    );

    let header;
    if (this.props.onClose != null) {
      header = (
        <TitleBar className='fixed-header' rightIcon='fa-times' rightIconOnClick={this.props.onClose}>
          {this.props.recipe.name}
        </TitleBar>
      );
    } else {
      header = <TitleBar className='fixed-header'>{this.props.recipe.name}</TitleBar>;
    }

    const footerButtons = [];

    // if (this.props.onEdit) {
    //   footerButtons.push(
    //     <IconButton key='edit' icon='fa-pencil-square-o' text='Edit' onClick={() => this.props.onEdit(this.props.recipe)} />
    //   );
    // }
    if (this.props.isShareable) {
      footerButtons.push(
        <IconButton
          key='share'
          icon='fa-share-square-o'
          text='Share'
          onClick={() => window.open(`sms:&body=${ this.props.recipe.name } ${ BASE_URL }/recipe/${ this.props.recipe.recipeId }`)}
        />
      );
    }
    if (this.props.onFavorite) {
      footerButtons.push(
        <IconButton
          key='favorite'
          icon={classNames({ 'fa-star': this.props.isFavorited, 'fa-star-o': !this.props.isFavorited })}
          text='Favorite'
          onClick={() => this.props.onFavorite!(this.props.recipe, !this.props.isFavorited)}
        />
      );
    }

    return (
      <div className='recipe-view fixed-header-footer'>
        {header}
        <div className='recipe-description fixed-content-pane'>
          <div className='recipe-ingredients'>
            {ingredients}
          </div>
          {instructions}
          {notes}
          {url}
        </div>
        {footerButtons.length ? <div className='fixed-footer'>{footerButtons}</div> : undefined}
      </div>
    );
  }

  _renderCategory(displayIngredients: (DisplayIngredient | SubstituteDisplayIngredient)[], category: string) {
    assert(this.props.ingredientsByTag);

    if (displayIngredients.length === 0) {
      return [];
    } else {
      let formattedIngredients: (MeasuredIngredientProps & { tag?: string })[];
      if (category === IngredientCategory.SUBSTITUTE) {
        formattedIngredients = displayIngredients.map((i: SubstituteDisplayIngredient) => defaults({
          isSubstituted: true,
          displaySubstitutes: i.have
        }, i.need));
      } else if (category === IngredientCategory.MISSING) {
        formattedIngredients = displayIngredients.map((i: DisplayIngredient) => {
          return defaults({
            isMissing: true,
            difficulty: this.props.ingredientsByTag![i.tag!].difficulty
          }, i);
        });
      } else {
        formattedIngredients = displayIngredients as DisplayIngredient[];
      }

      return formattedIngredients.map(i => <MeasuredIngredient {...i} key={`${ i.tag } ${ i.displayIngredient }`}/>);
    }
  }
}

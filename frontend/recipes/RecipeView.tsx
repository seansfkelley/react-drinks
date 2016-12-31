import { without } from 'lodash';
import * as React from 'react';
import * as classNames from 'classnames';

import { fractionify } from '../utils';
import { assert } from '../../shared/tinyassert';
import { Recipe, DisplayIngredient } from '../../shared/types';
import { BASE_URL } from '../../shared/definitions';

import TitleBar from '../components/TitleBar';

import MeasuredIngredient from './MeasuredIngredient';

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
  availableIngredientTags?: string[];
  onIngredientClick?: (tag: string) => void;
  onIngredientTagsChange?: (tags: string[]) => void;
  onSimilarRecipeClick?: (recipeId: string) => void;
  similarRecipes?: Recipe[];
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
    if (this.props.availableIngredientTags != null) {
      ingredients = this.props.recipe.ingredients.map(i =>
        <MeasuredIngredient
          ingredient={i}
          // TODO: This isn't quite right -- it doesn't do generics and all that jazz. But close enough for a demonstration.
          isAvailable={i.tag != null && this.props.availableIngredientTags!.includes(i.tag)}
          onAvailabilityToggle={this._onIngredientToggle}
          onClick={this.props.onIngredientClick}
          key={`${i.tag}~~~${i.displayIngredient}`}
        />
      );
    } else {
      ingredients = this.props.recipe.ingredients.map((i: DisplayIngredient) =>
        // This annoying key is because sometimes, the same tag will appear twice (e.g. Penicillin's two scotches).
        <MeasuredIngredient ingredient={i} key={`${i.tag}~~~${i.displayIngredient}`}/>
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
        {this.props.recipe.instructions.split('\n')
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

    let similarRecipes;
    if (this.props.similarRecipes && this.props.similarRecipes.length) {
      similarRecipes = (
        <div className='similar-recipes'>
          <div className='header'>Similar Drinks</div>
          <div className='recipe-list'>
            {this.props.similarRecipes.map(r =>
              <div
                key={r.recipeId}
                className='recipe'
                onClick={this.props.onSimilarRecipeClick ? () => this.props.onSimilarRecipeClick!(r.recipeId) : undefined}
              >
                {r.name}
              </div>
            )}
          </div>
        </div>
      );
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
          {similarRecipes}
        </div>
        {footerButtons.length ? <div className='fixed-footer'>{footerButtons}</div> : undefined}
      </div>
    );
  }

  private _onIngredientToggle = (tag: string) => {
    assert(this.props.availableIngredientTags);
    assert(this.props.onIngredientTagsChange);

    if (this.props.onIngredientTagsChange) {
      if (this.props.availableIngredientTags!.includes(tag)) {
        this.props.onIngredientTagsChange(without(this.props.availableIngredientTags!, tag));
      } else {
        this.props.onIngredientTagsChange(this.props.availableIngredientTags!.concat([ tag ]));
      }
    }
  };
}

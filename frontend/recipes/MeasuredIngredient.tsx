import * as React from 'react';
import * as classNames from 'classnames';

import { assert } from '../../shared/tinyassert';
import { DisplayIngredient } from '../../shared/types';
import { fractionify } from '../utils';

export interface Props {
  ingredient: DisplayIngredient;
  className?: string;
  isAvailable?: boolean;
  onAvailabilityToggle?: (tag: string, isAvailable: boolean) => void;
  onClick?: (tag: string) => void;
}

export default class MeasuredIngredient extends React.PureComponent<Props, void> {
  static defaultProps = {
    displayAmount: '',
    displayUnit: ''
  };

  render() {
    const hasTag = this.props.ingredient.tag != null;
    return (
      <div
        className={classNames('measured-ingredient', this.props.className)}
        onClick={hasTag && this.props.onClick ? this._onClick : undefined}
      >
        <span className='measure'>
          <span className='amount'>{fractionify(this.props.ingredient.displayAmount)}</span>
          {' '}
          <span className='unit'>{this.props.ingredient.displayUnit}</span>
        </span>
        <span className='ingredient'>
          <span className='name'>{this.props.ingredient.displayIngredient}</span>
        </span>
        {hasTag && this.props.onAvailabilityToggle
          ? <span className='toggle-button' onClick={this._onToggle}>
              <i className={classNames('fa', {
                'fa-plus-circle': !this.props.isAvailable,
                'fa-times-circle': this.props.isAvailable
              })}/>
            </span>
          : this.props.onAvailabilityToggle
            ? <span className='toggle-button placeholder'/>
            : null}
      </div>
    );
  }

  private _onClick = () => {
    assert(this.props.onClick);
    assert(this.props.ingredient.tag);
    this.props.onClick!(this.props.ingredient.tag!)
  };

  private _onToggle = (e: React.MouseEvent<HTMLElement>) => {
    assert(this.props.onAvailabilityToggle);
    assert(this.props.ingredient.tag);
    e.stopPropagation();
    this.props.onAvailabilityToggle!(this.props.ingredient.tag!, !this.props.isAvailable)
  };
}

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
}

export default class MeasuredIngredient extends React.PureComponent<Props, void> {
  static defaultProps = {
    displayAmount: '',
    displayUnit: ''
  };

  render() {
    const isToggleable = this.props.onAvailabilityToggle && this.props.ingredient.tag != null;
    return (
      <div
        className={classNames('measured-ingredient', this.props.className)}
        onClick={isToggleable ? this._onToggle : undefined}
      >
        <span className='measure'>
          <span className='amount'>{fractionify(this.props.ingredient.displayAmount)}</span>
          {' '}
          <span className='unit'>{this.props.ingredient.displayUnit}</span>
        </span>
        <span className='ingredient'>
          <span className='name'>{this.props.ingredient.displayIngredient}</span>
        </span>
        {isToggleable
          ? <span className='toggle-button'>
              <i className={classNames('fa', {
                'fa-plus-circle': !this.props.isAvailable,
                'fa-times-circle': this.props.isAvailable
              })}/>
            </span>
          : null}
      </div>
    );
  }

  private _onToggle = () => {
    assert(this.props.onAvailabilityToggle);
    assert(this.props.ingredient.tag);
    this.props.onAvailabilityToggle!(this.props.ingredient.tag!, !this.props.isAvailable)
  };
}

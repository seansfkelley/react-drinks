import * as React from 'react';
import * as classNames from 'classnames';

import { fractionify } from '../utils';
import { Difficulty, CLASS_NAME, HUMAN_READABLE } from '../Difficulty';

export interface Props {
  displayIngredient: string;
  displayAmount?: string;
  displayUnit?: string;
  displaySubstitutes?: string[];
  isMissing?: boolean;
  isSubstituted?: boolean;
  difficulty?: Difficulty;
  className?: string;
}

export default class extends React.PureComponent<Props, void> {
  static defaultProps = {
    displayAmount: '',
    displayUnit: '',
    displaySubstitutes: []
  };

  render() {
    return (
      <div className={classNames('measured-ingredient', this.props.className, {
          'missing': this.props.isMissing,
          'substituted': this.props.isSubstituted
        })}
      >
        <span className='measure'>
          {/* The space is necessary to space out the spans from each other. Newlines are insufficient.
              Include the keys only to keep React happy so that it warns us about significant uses of
              arrays without key props. */}
          <span className='amount'>{fractionify(this.props.displayAmount)}</span>{' '}
          <span className='unit'>{this.props.displayUnit}</span>
        </span>
        <span className='ingredient'>
          <span className='name'>{this.props.displayIngredient}</span>
          {this.props.displaySubstitutes && this.props.displaySubstitutes.length
            ? [
                <span className='substitute-label' key='label'>try:</span>,
                <span className='substitute-content' key='content'>
                  {(this.props as Props).displaySubstitutes!.map((sub, i) => <span key={i}>{sub}</span>)}
                </span>
              ]
            : undefined}
          {this.props.difficulty
            ? <span className={classNames('difficulty', CLASS_NAME[this.props.difficulty])}>
                {HUMAN_READABLE[this.props.difficulty]}
              </span>
            : undefined}
        </span>
      </div>
    );
  }
}

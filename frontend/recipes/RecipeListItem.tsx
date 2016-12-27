import * as React from 'react';
import * as classNames from 'classnames';

import { ListItem, DeletableListItem } from '../components/List';

import { Difficulty, CLASS_NAME, HUMAN_READABLE } from '../Difficulty';

interface Props {
  recipeName: string;
  difficulty?: Difficulty;
  isMixable?: boolean;
  onClick?: React.MouseEventHandler<HTMLElement>;
  onDelete?: Function;
}

export default class extends React.PureComponent<Props, void> {
  static defaultProps = {
    isMixable: true
  };

  render() {
    const difficulty = this.props.difficulty
      ? <span className={classNames('difficulty', CLASS_NAME[this.props.difficulty])} key='difficulty'>
          {HUMAN_READABLE[this.props.difficulty]}
        </span>
      : undefined;
    const content = [ <span className='name' key='name'>{this.props.recipeName}</span>, difficulty ];
    const className = classNames('recipe-list-item', { 'is-mixable': this.props.isMixable });
    return this.props.onDelete
      ? <DeletableListItem className={className} onClick={this.props.onClick} onDelete={this.props.onDelete}>{content}</DeletableListItem>
      : <ListItem className={className} onClick={this.props.onClick}>{content}</ListItem>;
  }
}



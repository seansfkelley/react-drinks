import * as React from 'react';
import * as classNames from 'classnames';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import List from '../components/List';

import { Difficulty, CLASS_NAME, HUMAN_READABLE } from '../Difficulty';

interface Props {
  recipeName: string;
  difficulty?: Difficulty;
  isMixable?: boolean;
  onClick?: Function;
  onDelete?: Function;
}

export default React.createClass<Props, void>({
  displayName: 'RecipeListItem',

  mixins: [PureRenderMixin],

  getDefaultProps() {
    return {
      isMixable: true
    } as any as Props;
  },

  render() {
    const difficulty = this.props.difficulty
      ? <span className={classNames('difficulty', CLASS_NAME[this.props.difficulty])} key='difficulty'>
          {HUMAN_READABLE[this.props.difficulty]}
        </span>
      : undefined;
    const content = [ <span className='name' key='name'>{this.props.recipeName}</span>, difficulty ];
    const className = classNames('recipe-list-item', { 'is-mixable': this.props.isMixable });
    return this.props.onDelete
      ? <List.DeletableItem className={className} onClick={this.props.onClick} onDelete={this.props.onDelete}>{content}</List.DeletableItem>
      : <List.Item className={className} onClick={this.props.onClick}>{content}</List.Item>;
  }
});



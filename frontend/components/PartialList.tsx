import * as React from 'react';
import * as classNames from 'classnames';

import { List } from './List';

interface Props<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
  emptyView?: React.ReactNode;
  softLimit?: number;
  hardLimit?: number;
  className?: string;
}

export default class PartialList<T> extends React.PureComponent<Props<T>, void> {
  static defaultProps = {
    emptyView: <div className='centered-list-text'>Nothing to see here.</div>,
    softLimit: 10,
    hardLimit: 20
  };

  render() {
    const itemsToRender = this.props.items.length > this.props.hardLimit
      ? this.props.items.slice(0, this.props.softLimit)
      : this.props.items;

    return (
      <List emptyView={this.props.emptyView} className={classNames(this.props.className, 'partial-list')}>
        {itemsToRender.map(this.props.renderItem)}
        {itemsToRender.length < this.props.items.length
          ? <div className='centered-list-text more-text'>...and {this.props.items.length - this.props.softLimit} more.</div>
          : undefined}
      </List>
    );
  }
}

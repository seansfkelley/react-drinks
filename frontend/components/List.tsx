import * as React from 'react';
import * as classNames from 'classnames';

import Deletable from './Deletable';

interface ListHeaderProps {
  title?: string;
  onClick?: React.MouseEventHandler<HTMLElement>;
  className?: string;
}

export class ListHeader extends React.PureComponent<ListHeaderProps, void> {
  render() {
    let children;
    if (React.Children.count(this.props.children) === 0) {
      children = <span className='text'>{this.props.title}</span>;
    } else {
      ({ children } = this.props);
    }

    return (
      <div className={classNames('list-header', this.props.className) } onClick={this.props.onClick}>
        {children}
      </div>
    );
  }
};

interface ListItemGroupProps {
  className?: string;
  style?: Object;
}

export class ListItemGroup extends React.PureComponent<ListItemGroupProps, void> {
  render() {
    return (
      <div className={classNames('list-group', this.props.className)} style={this.props.style}>
        {this.props.children}
      </div>
    );
  }
};

interface ListItemProps {
  className?: string;
  onClick?: React.MouseEventHandler<HTMLElement>;
}

export class ListItem extends React.PureComponent<ListItemProps, void> {
  render() {
    return (
      <div className={classNames('list-item', this.props.className)} onClick={this.props.onClick}>
        {this.props.children}
      </div>
    );
  }
};

interface DeletableListItemProps {
  className?: string;
  onClick?: React.MouseEventHandler<HTMLElement>;
  onDelete: Function; // ?
}

export class DeletableListItem extends React.PureComponent<DeletableListItemProps, void> {
  render() {
    return (
      <ListItem className={classNames('deletable-list-item', this.props.className)} onClick={this.props.onClick}>
        <Deletable onDelete={this.props.onDelete}>
          <div>{this.props.children}</div>
        </Deletable>
      </ListItem>
    );
  }
};

export const ListClassNames = {
  HEADERED: 'headered-list',
  COLLAPSIBLE: 'collapsible-list'
};

interface ListProps {
  emptyText?: string;
  emptyView?: React.ReactNode;
  className?: string;
  onTouchStart?: React.TouchEventHandler<HTMLElement>;
}

export class List extends React.PureComponent<ListProps, void> {
  static defaultProps = {
    emptyText: 'Nothing to see here.'
  };

  render() {
    let children;
    if (React.Children.toArray(this.props.children).filter(c => !!c).length === 0) {
      if (this.props.emptyView) {
        children = this.props.emptyView;
      } else {
        children = <div className='empty-list-text'>{this.props.emptyText}</div>;
      }
    } else {
      ({ children } = this.props);
    }

    return (
      <div
        className={classNames('list', this.props.className)}
        onTouchStart={this.props.onTouchStart}
      >
        {children}
      </div>
    );
  }
}

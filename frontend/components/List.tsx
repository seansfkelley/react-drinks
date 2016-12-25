import { assign } from 'lodash';
import * as React from 'react';
import * as classNames from 'classnames';

import Deletable from './Deletable';

interface HeaderProps {
  title?: string;
  onClick?: React.MouseEventHandler<void>;
}

const Header = React.createClass<HeaderProps, void>({
  displayName: 'List.Header',

  render() {
    let children;
    if (React.Children.count(this.props.children) === 0) {
      children = <span className='text'>{this.props.title}</span>;
    } else {
      ({ children } = this.props);
    }

    return (
      <div className={classNames('list-header', this.props.className) }>
        {children}
      </div>
    );
  }
});

interface ItemGroupProps {
  className?: string;
  style?: Object;
}

const ItemGroup = React.createClass<ItemGroupProps, void>({
  displayName: 'List.ItemGroup',

  render() {
    return (
      <div className={classNames('list-group', this.props.className)} style={this.props.style}>
        {this.props.children}
      </div>
    );
  }
});

interface ItemProps {
  className?: string;
  onClick?: React.MouseEventHandler<void>;
}

const Item = React.createClass<ItemProps, void>({
  displayName: 'List.Item',

  render() {
    return (
      <div className={classNames('list-item', this.props.className)} onClick={this.props.onClick}>
        {this.props.children}
      </div>
    );
  }
});

interface DeletableItemProps {
  className?: string;
  onClick?: React.MouseEventHandler<void>;
  onDelete: Function; // ?
}

const DeletableItem: React.ClassicComponentClass<DeletableItemProps> = React.createClass<DeletableItemProps, void>({
  displayName: 'List.DeletableItem',

  render() {
    return (
      <List.Item className={classNames('deletable-list-item', this.props.className) }>
        <Deletable onDelete={this.props.onDelete}>
          <div>{this.props.children}</div>
        </Deletable>
      </List.Item>
    );
  }
});

const ClassNames = {
  HEADERED: 'headered-list',
  COLLAPSIBLE: 'collapsible-list'
};

interface Props {
  emptyText?: string;
  emptyView?: React.ReactElement<any>;
  className?: string;
  onTouchStart?: React.TouchEventHandler<void>;
}

const List = assign(React.createClass<Props, void>({
  displayName: 'List',

  getDefaultProps() {
    return {
      emptyText: 'Nothing to see here.'
    };
  },

  render() {
    let children;
    if (React.Children.count(this.props.children) === 0) {
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
}), {
  Header,
  ItemGroup,
  Item,
  DeletableItem,
  ClassNames
});

export default List;

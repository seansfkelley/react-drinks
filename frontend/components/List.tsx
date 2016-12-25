import {} from 'lodash';
import * as React from 'react';
const Draggable = require('react-draggable');
const classnames = require('classnames');

const Deletable = require('./Deletable');

const List = React.createClass({
  displayName: 'List',

  propTypes: {
    emptyText: React.PropTypes.string,
    emptyView: React.PropTypes.element
  },

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

    const renderableProps = _.omit(this.props, 'emptyView', 'emptyText');
    return <div {...Object.assign({}, renderableProps, { "className": classnames('list', this.props.className) })}>{children}</div>;
  }
});

List.Header = React.createClass({
  displayName: 'List.Header',

  propTypes: {
    title: React.PropTypes.string
  },

  render() {
    let children;
    if (React.Children.count(this.props.children) === 0) {
      children = <span className='text'>{this.props.title}</span>;
    } else {
      ({ children } = this.props);
    }

    const renderableProps = _.omit(this.props, 'title');
    return <div {...Object.assign({}, renderableProps, { "className": classnames('list-header', this.props.className) })}>{children}</div>;
  }
});

List.ItemGroup = React.createClass({
  displayName: 'List.ItemGroup',

  propTypes: {},

  render() {
    return <div {...Object.assign({}, this.props, { "className": classnames('list-group', this.props.className) })}>{this.props.children}</div>;
  }
});

List.Item = React.createClass({
  displayName: 'List.Item',

  propTypes: {},

  render() {
    return <div {...Object.assign({}, this.props, { "className": classnames('list-item', this.props.className) })}>{this.props.children}</div>;
  }
});

List.DeletableItem = React.createClass({
  displayName: 'List.DeletableItem',

  propTypes: {
    onDelete: React.PropTypes.func.isRequired
  },

  render() {
    const renderableProps = _.omit(this.props, 'onDelete');
    return <List.Item {...Object.assign({}, renderableProps, { "className": classnames('deletable-list-item', this.props.className) })}><Deletable onDelete={this.props.onDelete}><div>{this.props.children}</div></Deletable></List.Item>;
  }
});

List.AddableItem = React.createClass({
  displayName: 'List.AddableItem',

  propTypes: {
    placeholder: React.PropTypes.string,
    onAdd: React.PropTypes.func.isRequired
  },

  getDefaultProps() {
    return {
      placeholder: 'Add...'
    };
  },

  getInitialState() {
    return {
      isEditing: false,
      value: ''
    };
  },

  render() {
    return <List.Item className='addable-list-item'><input onFocus={this._setEditing} onBlur={this._clearEditing} onChange={this._setValue} value={this.state.value} placeholder={this.props.placeholder} type='text' autoCorrect='off' autoCapitalize='off' autoComplete='off' spellCheck='false' ref='input' /><i className={classnames('fa fa-plus', { 'enabled': this.state.isEditing || this.state.value })} onClick={this._add} /></List.Item>;
  },

  _setEditing() {
    return this.setState({ isEditing: false });
  },

  _clearEditing() {
    return this.setState({
      value: this.state.value.trim(),
      isEditing: false
    });
  },

  _setValue(e) {
    return this.setState({ value: e.target.value });
  },

  _add() {
    return this.props.onAdd(this.state.value);
  }
});

List.ClassNames = {
  HEADERED: 'headered-list',
  COLLAPSIBLE: 'collapsible-list'
};

module.exports = List;

const _          = require('lodash');
const React      = require('react');
const Draggable  = require('react-draggable');
const classnames = require('classnames');

const Deletable = require('./Deletable');

const List = React.createClass({
  displayName : 'List',

  propTypes : {
    emptyText : React.PropTypes.string,
    emptyView : React.PropTypes.element
  },

  getDefaultProps() { return {
    emptyText : 'Nothing to see here.'
  }; },

  render() {
    let children;
    if (React.Children.count(this.props.children) === 0) {
      if (this.props.emptyView) {
        children = this.props.emptyView;
      } else {
        children = React.createElement("div", {"className": 'empty-list-text'}, (this.props.emptyText));
      }
    } else {
      ({ children } = this.props);
    }

    const renderableProps = _.omit(this.props, 'emptyView', 'emptyText');
    return React.createElement("div", Object.assign({},  renderableProps, {"className": (classnames('list', this.props.className))}),
      (children)
    );
  }
});

List.Header = React.createClass({
  displayName : 'List.Header',

  propTypes : {
    title : React.PropTypes.string
  },

  render() {
    let children;
    if (React.Children.count(this.props.children) === 0) {
      children = React.createElement("span", {"className": 'text'}, (this.props.title));
    } else {
      ({ children } = this.props);
    }

    const renderableProps = _.omit(this.props, 'title');
    return React.createElement("div", Object.assign({},  renderableProps, {"className": (classnames('list-header', this.props.className))}),
      (children)
    );
  }
});

List.ItemGroup = React.createClass({
  displayName : 'List.ItemGroup',

  propTypes : {},

  render() {
    return React.createElement("div", Object.assign({},  this.props, {"className": (classnames('list-group', this.props.className))}),
      (this.props.children)
    );
  }
});

List.Item = React.createClass({
  displayName : 'List.Item',

  propTypes : {},

  render() {
    return React.createElement("div", Object.assign({},  this.props, {"className": (classnames('list-item', this.props.className))}),
      (this.props.children)
    );
  }
});

List.DeletableItem = React.createClass({
  displayName : 'List.DeletableItem',

  propTypes : {
    onDelete : React.PropTypes.func.isRequired
  },

  render() {
    const renderableProps = _.omit(this.props, 'onDelete');
    return React.createElement(List.Item, Object.assign({},  renderableProps, {"className": (classnames('deletable-list-item', this.props.className))}),
      React.createElement(Deletable, {"onDelete": (this.props.onDelete)},
        React.createElement("div", null,
          (this.props.children)
        )
      )
    );
  }
});

List.AddableItem = React.createClass({
  displayName : 'List.AddableItem',

  propTypes : {
    placeholder : React.PropTypes.string,
    onAdd       : React.PropTypes.func.isRequired
  },

  getDefaultProps() { return {
    placeholder : 'Add...'
  }; },

  getInitialState() { return {
    isEditing : false,
    value     : ''
  }; },

  render() {
    return React.createElement(List.Item, {"className": 'addable-list-item'},
      React.createElement("input", { 
        "onFocus": (this._setEditing),  
        "onBlur": (this._clearEditing),  
        "onChange": (this._setValue),  
        "value": (this.state.value),  
        "placeholder": (this.props.placeholder),  
        "type": 'text',  
        "autoCorrect": 'off',  
        "autoCapitalize": 'off',  
        "autoComplete": 'off',  
        "spellCheck": 'false',  
        "ref": 'input'
      }),
      React.createElement("i", {"className": (classnames('fa fa-plus', { 'enabled' : this.state.isEditing || this.state.value })), "onTouchTap": (this._add)})
    );
  },

  _setEditing() {
    return this.setState({ isEditing : false });
  },

  _clearEditing() {
    return this.setState({
      value     : this.state.value.trim(),
      isEditing : false
    });
  },

  _setValue(e) {
    return this.setState({ value : e.target.value });
  },

  _add() {
    return this.props.onAdd(this.state.value);
  }
});

List.ClassNames = {
  HEADERED    : 'headered-list',
  COLLAPSIBLE : 'collapsible-list'
};

module.exports = List;

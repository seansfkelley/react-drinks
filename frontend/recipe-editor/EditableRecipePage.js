const React           = require('react');
const classnames      = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const store = require('../store');

const NavigationHeader = React.createClass({
  displayName : 'NavigationHeader',

  propTypes : {
    onClose       : React.PropTypes.func.isRequired,
    previousTitle : React.PropTypes.string,
    onPrevious    : React.PropTypes.func
  },

  mixins : [
    PureRenderMixin
  ],

  render() {
    return React.createElement("div", {"className": 'navigation-header fixed-header'},
      (this.props.previousTitle && this.props.onPrevious ? React.createElement("div", {"className": 'back-button float-left', "onTouchTap": (this.props.onPrevious)},
        React.createElement("i", {"className": 'fa fa-chevron-left'}),
        React.createElement("span", {"className": 'back-button-label'}, (this.props.previousTitle))
      ) : undefined),
      React.createElement("i", {"className": 'fa fa-times float-right', "onTouchTap": (this._close)})
    );
  },

  _close() {
    store.dispatch({
      type : 'clear-editable-recipe'
    });

    return this.props.onClose();
  }
});

const EditableRecipePage = React.createClass({
  displayName : 'EditableRecipePage',

  propTypes : {
    onClose       : React.PropTypes.func.isRequired,
    onPrevious    : React.PropTypes.func,
    previousTitle : React.PropTypes.string,
    className     : React.PropTypes.string
  },

  render() {
    return React.createElement("div", {"className": (classnames('editable-recipe-page fixed-header-footer', this.props.className))},
      React.createElement(NavigationHeader, {"onClose": (this.props.onClose), "previousTitle": (this.props.previousTitle), "onPrevious": (this.props.onPrevious)}),
      (this.props.children)
    );
  }
});

module.exports = EditableRecipePage;

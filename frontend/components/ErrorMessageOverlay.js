const React           = require('react');
const PureRenderMixin = require('react-addons-pure-render-mixin');
const classnames      = require('classnames');

const ReduxMixin = require('../mixins/ReduxMixin');

const ErrorMessageOverlay = React.createClass({
  displayName : 'ErrorMessageOverlay',

  propTypes : {},

  mixins : [
    ReduxMixin({
      ui : 'errorMessage'
    }),
    PureRenderMixin
  ],

  render() {
    let content;
    if (!this.state.errorMessage) {
      content = null;
    } else {
      content = React.createElement("div", {"className": 'error-message'},
        React.createElement("i", {"className": 'fa fa-exclamation-circle'}),
        React.createElement("div", {"className": 'message-text'}, (this.state.errorMessage))
      );
    }

    return React.createElement("div", {"className": (classnames('error-message-overlay', { 'visible' : this.state.errorMessage }) )},
      (content)
    );
  }
});

module.exports = ErrorMessageOverlay;

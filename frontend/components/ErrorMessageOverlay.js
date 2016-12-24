const React = require('react');
const PureRenderMixin = require('react-addons-pure-render-mixin');
const classnames = require('classnames');

const ReduxMixin = require('../mixins/ReduxMixin');

const ErrorMessageOverlay = React.createClass({
  displayName: 'ErrorMessageOverlay',

  propTypes: {},

  mixins: [ReduxMixin({
    ui: 'errorMessage'
  }), PureRenderMixin],

  render() {
    let content;
    if (!this.state.errorMessage) {
      content = null;
    } else {
      content = <div className='error-message'><i className='fa fa-exclamation-circle' /><div className='message-text'>{this.state.errorMessage}</div></div>;
    }

    return <div className={classnames('error-message-overlay', { 'visible': this.state.errorMessage })}>{content}</div>;
  }
});

module.exports = ErrorMessageOverlay;
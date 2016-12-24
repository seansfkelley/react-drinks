const _ = require('lodash');
const React = require('react');
const classnames = require('classnames');

const Overlay = React.createClass({
  displayName: 'Overlay',

  propTypes: {
    isVisible: React.PropTypes.bool.isRequired,
    type: React.PropTypes.oneOf(['modal', 'flyup', 'pushover']).isRequired,
    children: React.PropTypes.element
  },

  render() {
    return <div className={classnames('overlay', { 'visible': this.props.isVisible }, this.props.type)}>{this.props.children}</div>;
  }
});

module.exports = Overlay;
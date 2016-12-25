import * as React from 'react';
const classnames = require('classnames');

const TitleBar = React.createClass({
  displayName: 'TitleBar',

  propTypes: {
    leftIcon: React.PropTypes.string,
    children: React.PropTypes.node,
    rightIcon: React.PropTypes.string,
    leftIconOnTouchTap: React.PropTypes.func,
    onClick: React.PropTypes.func,
    rightIconOnTouchTap: React.PropTypes.func
  },

  render() {
    let leftIcon, rightIcon;
    if (this.props.leftIcon != null) {
      if (this.props.leftIcon.slice(0, 2) === 'fa') {
        leftIcon = <i className={`fa float-left ${ this.props.leftIcon }`} onClick={this.props.leftIconOnTouchTap} />;
      } else {
        leftIcon = <img src={this.props.leftIcon} onClick={this.props.leftIconOnTouchTap} />;
      }
    }

    if (this.props.rightIcon != null) {
      if (this.props.rightIcon.slice(0, 2) === 'fa') {
        rightIcon = <i className={`fa float-right ${ this.props.rightIcon }`} onClick={this.props.rightIconOnTouchTap} />;
      } else {
        rightIcon = <img src={this.props.rightIcon} onClick={this.props.rightIconOnTouchTap} />;
      }
    }

    const showingIcons = this.props.leftIcon != null || this.props.rightIcon != null;

    if (showingIcons) {
      if (leftIcon == null) {
        leftIcon = <span className='spacer float-left'> </span>;
      }
      if (rightIcon == null) {
        rightIcon = <span className='spacer float-right'> </span>;
      }
    }

    return <div className={classnames('title-bar', this.props.className)}>{leftIcon}{React.Children.count(this.props.children) > 0 ? <div className={classnames('title', { 'showing-icons': showingIcons })} onClick={this.props.onClick}>{this.props.children}</div> : undefined}{rightIcon}</div>;
  }
});

module.exports = TitleBar;

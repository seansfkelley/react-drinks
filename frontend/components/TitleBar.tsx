import * as React from 'react';
import * as classNames from 'classnames';

interface Props {
  leftIcon?: string;
  rightIcon?: string;
  leftIconOnClick?: React.MouseEventHandler<HTMLElement>;
  onClick?: React.MouseEventHandler<HTMLElement>;
  rightIconOnClick?: React.MouseEventHandler<HTMLElement>;
  className?: string;
}

export default class extends React.PureComponent<Props, void> {
  render() {
    let leftIcon, rightIcon;
    if (this.props.leftIcon != null) {
      if (this.props.leftIcon.slice(0, 2) === 'fa') {
        leftIcon = <i className={`fa ${ this.props.leftIcon }`} onClick={this.props.leftIconOnClick} />;
      } else {
        leftIcon = <img src={this.props.leftIcon} onClick={this.props.leftIconOnClick} />;
      }
    }

    if (this.props.rightIcon != null) {
      if (this.props.rightIcon.slice(0, 2) === 'fa') {
        rightIcon = <i className={`fa ${ this.props.rightIcon }`} onClick={this.props.rightIconOnClick} />;
      } else {
        rightIcon = <img src={this.props.rightIcon} onClick={this.props.rightIconOnClick} />;
      }
    }

    const showingIcons = this.props.leftIcon != null || this.props.rightIcon != null;

    if (showingIcons) {
      if (leftIcon == null) {
        leftIcon = <span className='spacer'> </span>;
      }
      if (rightIcon == null) {
        rightIcon = <span className='spacer'> </span>;
      }
    }

    return (
      <div className={classNames('title-bar', this.props.className)}>
        {leftIcon}
        {React.Children.count(this.props.children) > 0
          ? <div
              className={classNames('title', { 'showing-icons': showingIcons })}
              onClick={this.props.onClick}
            >
              {this.props.children}
            </div>
          : undefined}
        {rightIcon}
      </div>
    );
  }
}

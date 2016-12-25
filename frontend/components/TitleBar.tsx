import * as React from 'react';
import * as classNames from 'classnames';

interface Props {
  leftIcon?: string;
  rightIcon?: string;
  leftIconOnClick?: React.MouseEventHandler<void>;
  onClick?: React.MouseEventHandler<void>;
  rightIconOnClick?: React.MouseEventHandler<void>;
  className?: string;
}

export default React.createClass<Props, void>({
  displayName: 'TitleBar',

  render() {
    let leftIcon, rightIcon;
    if (this.props.leftIcon != null) {
      if (this.props.leftIcon.slice(0, 2) === 'fa') {
        leftIcon = <i className={`fa float-left ${ this.props.leftIcon }`} onClick={this.props.leftIconOnClick} />;
      } else {
        leftIcon = <img src={this.props.leftIcon} onClick={this.props.leftIconOnClick} />;
      }
    }

    if (this.props.rightIcon != null) {
      if (this.props.rightIcon.slice(0, 2) === 'fa') {
        rightIcon = <i className={`fa float-right ${ this.props.rightIcon }`} onClick={this.props.rightIconOnClick} />;
      } else {
        rightIcon = <img src={this.props.rightIcon} onClick={this.props.rightIconOnClick} />;
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
});

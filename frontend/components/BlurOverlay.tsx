import * as React from 'react';
import * as classNames from 'classnames';

interface Props {
  background: React.ReactNode;
  foreground?: React.ReactNode;
  isDark?: boolean;
  onBackdropClick?: () => void;
}

export default class BlurOverlay extends React.PureComponent<Props, void> {
  static defaultProps = {
    isDark: true
  };

  render() {
    return (
      <div className={classNames('blur-overlay', { 'with-foreground': !!this.props.foreground })}>
        <div className='child-container background'>{this.props.background}</div>
        <div className='backdrop' onClick={this.props.onBackdropClick}/>
        <div className='child-container foreground'>{this.props.foreground}</div>
      </div>
    );
  }
}
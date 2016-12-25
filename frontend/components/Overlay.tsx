import * as React from 'react';
import * as classNames from 'classnames';

interface Props {
  isVisible: boolean;
  type: 'modal' | 'flyup' | 'pushover';
}

export default React.createClass<Props, void>({
  displayName: 'Overlay',

  render() {
    return (
      <div className={classNames('overlay', { 'visible': this.props.isVisible }, this.props.type)}>
        {this.props.children}
      </div>
    );
  }
});

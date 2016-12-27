import * as React from 'react';
import * as classNames from 'classnames';

interface Props {
  isVisible: boolean;
  type: 'modal' | 'flyup' | 'pushover';
}

const Overlay: React.StatelessComponent<Props> = (props) => (
  <div className={classNames('overlay', { 'visible': props.isVisible }, props.type)}>
    {props.children}
  </div>
);

export default Overlay;

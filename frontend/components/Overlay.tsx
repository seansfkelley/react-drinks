import * as React from 'react';
import * as classNames from 'classnames';

interface Props {
  isVisible: boolean;
  type: 'modal' | 'flyup' | 'pushover';
  onBackdropClick?: () => void;
}

const Overlay: React.StatelessComponent<Props> = (props) => (
  <div className={classNames('overlay', { 'visible': props.isVisible }, props.type)}>
    <div className='overlay-backdrop' onClick={props.onBackdropClick}/>
    {props.children}
  </div>
);

export default Overlay;

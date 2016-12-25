import { defer, delay } from 'lodash';
import * as React from 'react';
import { render, findDOMNode, unmountComponentAtNode } from 'react-dom';

import { TRANSITION_DURATION } from '../../stylingConstants';

const DOM_NODE = document.querySelector('#web-clip-notification')!;

const WebClipNotification = React.createClass({
  displayName: 'WebClipNotification',

  render() {
    return (
      <div className='web-clip-notification arrow-box hidden' onClick={this._dismiss}>
        <span className='request'>
          <span className='lead-in'>Hey there first-timer!</span>
          Tap
          <img src='/assets/img/ios-export.png' />
          to save Spirit Guide to your home screen. That gets rid of the top and bottom bars, to boot!
        </span>
        <br />
        <span className='dismiss'>Tap this note to dismiss it permanently.</span>
      </div>
    );
  },

  componentDidMount() {
    defer(() => {
      findDOMNode(this).classList.remove('hidden');
    });
  },

  _dismiss() {
    findDOMNode(this).classList.add('hidden');
    DOM_NODE.classList.add('hidden');
    delay(() => {
      unmountComponentAtNode(DOM_NODE);
    }, TRANSITION_DURATION);
  }

});

const IS_IPHONE = window.navigator.userAgent.indexOf('iPhone') !== -1;
const LOCALSTORAGE_KEY = 'drinks-app-web-clip-notification';

export function renderIfAppropriate() {
  if (IS_IPHONE && !localStorage[LOCALSTORAGE_KEY] && !(window.navigator as any).standalone) {
    localStorage[LOCALSTORAGE_KEY] = true;
    DOM_NODE.classList.remove('hidden');
    render(<WebClipNotification />, DOM_NODE);
  }
}

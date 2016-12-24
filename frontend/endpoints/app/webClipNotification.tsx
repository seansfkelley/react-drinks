import {} from 'lodash';
const React = require('react');
const ReactDOM = require('react-dom');

const stylingConstants = require('../../stylingConstants');

const DOM_NODE = document.querySelector('#web-clip-notification');

const WebClipNotification = React.createClass({
  displayName: 'WebClipNotification',

  render() {
    return <div className='web-clip-notification arrow-box hidden' onTouchTap={this._dismiss}><span className='request'><span className='lead-in'>Hey there first-timer!</span>Tap<img src='/assets/img/ios-export.png' />{` to save Spirit Guide to your home screen.
That gets rid of the top and bottom bars, to boot!`}</span><br /><span className='dismiss'>Tap this note to dismiss it permanently.</span></div>;
  },

  componentDidMount() {
    return _.defer(() => {
      return ReactDOM.findDOMNode(this).classList.remove('hidden');
    });
  },

  _dismiss() {
    ReactDOM.findDOMNode(this).classList.add('hidden');
    DOM_NODE.classList.add('hidden');
    return _.delay(() => {
      return ReactDOM.unmountComponentAtNode(DOM_NODE);
    }, stylingConstants.TRANSITION_DURATION);
  }

});

const IS_IPHONE = window.navigator.userAgent.indexOf('iPhone') !== -1;
const LOCALSTORAGE_KEY = 'drinks-app-web-clip-notification';

module.exports = {
  renderIfAppropriate() {
    if (IS_IPHONE && !localStorage[LOCALSTORAGE_KEY] && !window.navigator.standalone) {
      localStorage[LOCALSTORAGE_KEY] = true;
      DOM_NODE.classList.remove('hidden');
      return ReactDOM.render(<WebClipNotification />, DOM_NODE);
    }
  }
};

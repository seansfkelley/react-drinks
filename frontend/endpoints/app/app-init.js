require('../common-init')();
require('../debug-init')();

// Kick off requests ASAP.
const initializationPromise = require('../../store/init')();

const _        = require('lodash');
const ReactDOM = require('react-dom');
const Promise  = require('bluebird');

const App                 = require('./App');
const ErrorMessageOverlay = require('../../components/ErrorMessageOverlay');
const webClipNotification = require('./webClipNotification');

const store       = require('../../store');
const derived     = require('../../store/derived');
const persistence = require('../../store/persistence');

const LOADING_OVERLAY    = document.querySelector('#main-loading-overlay');
const APP_ROOT           = document.querySelector('#app-root');
const ERROR_MESSAGE_ROOT = document.querySelector('#error-message-root');

const onUnhandledError = () =>
  // TODO: Ship this back to the server for debuggin'.
  store.dispatch({
    type    : 'error-message',
    message : 'Uh oh, something bad happened! Try reloading to fix it.'
  })
;

Promise.onPossiblyUnhandledRejection(onUnhandledError);
window.onerror = onUnhandledError;

// By racing these, we ensure we don't pop up the text right as the overlay is fading out.
Promise.any([
  Promise.delay(3000).return(true),
  initializationPromise.return(false)
])
.then(function(showText) {
  if (showText) {
    return LOADING_OVERLAY.classList.add('show-waiting-text');
  }
});

initializationPromise
.then(function() {
  persistence.watch(store);
  // The idea is to refresh the timestamps, even if the user doesn't interact. Opening the app
  // should be sufficient interaction to reset the timers on all the expirable pieces of state.
  store.dispatch({
    type : '--dummy-event-to-trigger-persistence--'
  });

  ReactDOM.render(React.createElement(App, null), APP_ROOT);

  webClipNotification.renderIfAppropriate();

  return LOADING_OVERLAY.classList.add('fade-out');
})
.catch((e) => {
  console.log(e);
  store.dispatch({
    type    : 'error-message',
    message : 'There was an error loading data from the server! Try reloading.'
  });
});

ReactDOM.render(React.createElement(ErrorMessageOverlay, null), ERROR_MESSAGE_ROOT);

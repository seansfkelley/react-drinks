import commonInit from '../common-init';
import debugInit from '../debug-init';
import storeInit from '../../store/init';

commonInit();
debugInit();

// Kick off requests ASAP.
const initializationPromise = storeInit();

import * as React from 'react';
import { render } from 'react-dom';
import * as Promise from 'bluebird';
import { Provider } from 'react-redux';

import App from './App';
import ErrorMessageOverlay from '../../components/ErrorMessageOverlay';
import { renderIfAppropriate as renderWebClipNotificationIfAppropriate } from './webClipNotification';

import { store } from '../../store';
import { watch as watchStore } from '../../store/persistence';
import { setErrorMessage, noopTriggerPersistence } from '../../store/atomicActions';

const LOADING_OVERLAY = document.querySelector('#main-loading-overlay')!;
const APP_ROOT = document.querySelector('#app-root')!;
const ERROR_MESSAGE_ROOT = document.querySelector('#error-message-root')!;

function onUnhandledError() {
  // TODO: Ship this back to the server for debuggin'.
  store.dispatch(setErrorMessage('Uh oh, something bad happened! Try reloading to fix it.'));
}

Promise.onPossiblyUnhandledRejection(onUnhandledError);
window.onerror = onUnhandledError;

// By racing these, we ensure we don't pop up the text right as the overlay is fading out.
Promise.any([ Promise.delay(3000).return(true), initializationPromise.return(false) ])
  .then(function (showText) {
    if (showText) {
      return LOADING_OVERLAY.classList.add('show-waiting-text');
    }
  });

initializationPromise.then(function () {
  watchStore(store);
  store.dispatch(noopTriggerPersistence());

  render(<Provider store={store}><App/></Provider>, APP_ROOT);
  renderWebClipNotificationIfAppropriate();
  LOADING_OVERLAY.classList.add('fade-out');

}).catch(e => {
  console.log(e);
  store.dispatch(setErrorMessage('There was an error loading data from the server! Try reloading.'));
});

render(<Provider store={store}><ErrorMessageOverlay /></Provider>, ERROR_MESSAGE_ROOT);

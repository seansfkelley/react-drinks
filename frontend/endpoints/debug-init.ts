import * as _ from 'lodash';
import { once, mapValues } from 'lodash';
import * as React from 'react';
import * as ReactPerf from 'react-addons-perf';
import * as reqwest from 'reqwest';
import * as log from 'loglevel';

import { store } from '../store';

export default once(() => {
  (window as any).getJquery = () => {
    const jq = document.createElement('script');
    jq.src = 'https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.js';
    document.getElementsByTagName('head')[0].appendChild(jq);
  };

  (window as any).reactPerf = ReactPerf;

  (window as any).debug = {
    log,

    localStorage() {
      return mapValues(localStorage, function (v) {
        try {
          return JSON.parse(v);
        } catch (error) {
          return v;
        }
      });
    },

    clearLocalStorage({ force } = { force: false }) {
      if (!force) {
        return console.error('pass the \'force\' option if you really mean it');
      } else {
        return delete localStorage['drinks-app-persistence'];
      }
    },

    getState() {
      return store.getState();
    },

    reactPerf(timeout = 2000) {
      ReactPerf.start();
      return setTimeout(function () {
        ReactPerf.stop();
        return ReactPerf.printWasted();
      }, timeout);
    }
  };

  // For devtools.
  (window as any).React = React;
  // Because I use these a lot.
  (window as any)._ = _;
  (window as any).reqwest = reqwest;
});

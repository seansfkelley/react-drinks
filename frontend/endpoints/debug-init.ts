const _ = require('lodash');
const React = require('react');
const ReactPerf = require('react-addons-perf');
const reqwest = require('reqwest');

module.exports = _.once(function () {
  window.getJquery = function () {
    const jq = document.createElement('script');
    jq.src = 'https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.js';
    return document.getElementsByTagName('head')[0].appendChild(jq);
  };

  window.reactPerf = ReactPerf;

  window.debug = {
    log: require('loglevel'),

    localStorage() {
      return _.mapValues(localStorage, function (v) {
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
      return require('../store').getState();
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
  window.React = React;
  // Because I use these a lot.
  window._ = _;
  return window.reqwest = reqwest;
});
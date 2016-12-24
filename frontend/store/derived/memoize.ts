const _ = require('lodash');

module.exports = function (fn) {
  let lastArg = null;
  let lastResult = null;

  return function (arg) {
    if (_.all(arg, (value, key) => __guard__(lastArg, x => x[key]) === value)) {
      return lastResult;
    } else {
      lastArg = arg;
      lastResult = fn(arg);
      return lastResult;
    }
  };
};

function __guard__(value, transform) {
  return typeof value !== 'undefined' && value !== null ? transform(value) : undefined;
}
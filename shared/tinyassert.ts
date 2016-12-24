const assert = function (condition, message = null) {
  if (!condition) {
    throw new Error(message != null ? message : 'Assertion error');
  }
};

module.exports = assert;


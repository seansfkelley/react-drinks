import {} from 'lodash';

const store = require('../store');
const derived = require('../store/derived');

const DerivedValueMixin = function (...fieldNames) {
  fieldNames = _.flatten(fieldNames);
  const fnName = _.uniqueId('_onStoreChange_');
  const getDerivedFields = function () {
    const state = store.getState();
    return _.reduce(fieldNames, function (fields, fieldName) {
      fields[fieldName] = derived[fieldName](state);
      return fields;
    }, {});
  };

  const mixin = {
    getInitialState: getDerivedFields,

    componentDidMount() {
      return this._derivedValueMixin_unsubscribe = store.subscribe(this[fnName]);
    },

    componentWillUnmount() {
      return __guardMethod__(this, '_derivedValueMixin_unsubscribe', o => o._derivedValueMixin_unsubscribe());
    }
  };

  mixin[fnName] = function () {
    return this.setState(getDerivedFields());
  };

  return mixin;
};

module.exports = DerivedValueMixin;

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}

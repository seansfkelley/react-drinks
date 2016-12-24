import {} from 'lodash';

const store = require('../store');

const ReduxMixin = function (fieldsBySubstore) {
  const fnName = _.uniqueId('_onStoreChange_');
  const getFlattenedFields = function () {
    const state = store.getState();
    return _.extend({}, ..._.map(fieldsBySubstore, (fieldArrayOrString, storeName) => _.pick(state[storeName], fieldArrayOrString)));
  };

  const mixin = {
    getInitialState: getFlattenedFields,

    componentDidMount() {
      return this._reduxMixin_unsubscribe = store.subscribe(this[fnName]);
    },

    componentWillUnmount() {
      return __guardMethod__(this, '_reduxMixin_unsubscribe', o => o._reduxMixin_unsubscribe());
    }
  };

  mixin[fnName] = function () {
    return this.setState(getFlattenedFields());
  };

  return mixin;
};

module.exports = ReduxMixin;

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}

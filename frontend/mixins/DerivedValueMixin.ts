import { flatten, uniqueId } from 'lodash';

const store = require('../store');
const derived = require('../store/derived');

export default function(...fieldNames: string[]) {
  fieldNames = flatten(fieldNames);
  const fnName = uniqueId('_onStoreChange_');
  const getDerivedFields = function () {
    const state = store.getState();
    return fieldNames.reduce((fields, fieldName) => {
      (fields as any)[fieldName] = derived[fieldName](state);
      return fields;
    }, {});
  };

  const mixin = {
    getInitialState: getDerivedFields,

    componentDidMount() {
      return this._derivedValueMixin_unsubscribe = store.subscribe(this[fnName]);
    },

    componentWillUnmount() {
      if (this._derivedValueMixin_unsubscribe) {
        this._derivedValueMixin_unsubscribe();
      }
    }
  };

  (mixin as any)[fnName] = function () {
    return this.setState(getDerivedFields());
  };

  return mixin;
};

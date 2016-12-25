import { flattenDeep, uniqueId } from 'lodash';

import { store } from '../store';
import * as derived from '../store/derived';

export default function(...fieldNames: (string | string[])[]) {
  const flattenedFieldNames = flattenDeep(fieldNames) as string[];
  const fnName = uniqueId('_onStoreChange_');
  const getDerivedFields = function () {
    const state = store.getState();
    return flattenedFieldNames.reduce((fields, fieldName) => {
      (fields as any)[fieldName] = (derived as any)[fieldName](state);
      return fields;
    }, {});
  };

  const mixin = {
    getInitialState: getDerivedFields,

    componentDidMount() {
      this._derivedValueMixin_unsubscribe = store.subscribe(this[fnName]);
    },

    componentWillUnmount() {
      if (this._derivedValueMixin_unsubscribe) {
        this._derivedValueMixin_unsubscribe();
      }
    }
  };

  (mixin as any)[fnName] = function () {
    this.setState(getDerivedFields());
  };

  return mixin;
};

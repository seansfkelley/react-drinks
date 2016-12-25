import { map, uniqueId, assign, pick } from 'lodash';
import { store } from '../store';

export default function(fieldsBySubstore: { [store: string]: string | string[] }) {
  const fnName = uniqueId('_onStoreChange_');
  function getFlattenedFields() {
    const state = store.getState();
    return assign({}, ...map(fieldsBySubstore, (fieldArrayOrString, storeName) => pick((state as any)[storeName!], fieldArrayOrString)));
  }

  const mixin = {
    getInitialState: getFlattenedFields,

    componentDidMount() {
      return this._reduxMixin_unsubscribe = store.subscribe(this[fnName]);
    },

    componentWillUnmount() {
      if (this._reduxMixin_unsubscribe) {
        this._reduxMixin_unsubscribe();
      }
    }
  };

  (mixin as any)[fnName] = function () {
    return this.setState(getFlattenedFields());
  };

  return mixin;
};

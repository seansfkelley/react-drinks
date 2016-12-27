import { Action } from '../ActionType';

export default function<S>(defaultState: S, actionNameToFunctionMap: { [action: string]: (state: S, action: Action<any>) => S }) {
  return function (state: S, action: Action<any>): S {
    if (state == null) {
      return defaultState;
    } else if (actionNameToFunctionMap[action.type]) {
      return actionNameToFunctionMap[action.type](state, action);
    } else {
      return state;
    }
  };
}

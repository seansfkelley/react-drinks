import { Action, ActionType } from '../ActionType';

export default function<S>(defaultState: S, actionNameToFunctionMap: { [T in ActionType]?: (state: S, action: Action<any>) => S }) {
  return function (state: S, action: Action<any>): S {
    if (state == null) {
      return defaultState;
    } else {
      const fn = actionNameToFunctionMap[action.type];
      if (typeof fn === 'function') {
        return fn(state, action);
      } else {
        return state;
      }
    }
  };
}

export default function<T>(defaultState: T, actionNameToFunctionMap: { [action: string]: (state: T, action: any) => T }) {
  return function (state: T, action: any): T {
    let fn: (state: T, action: any) => T;
    if (state == null) {
      return defaultState;
    } else if (fn = actionNameToFunctionMap[action.type]) {
      return fn(state, action);
    } else {
      return state;
    }
  };
}

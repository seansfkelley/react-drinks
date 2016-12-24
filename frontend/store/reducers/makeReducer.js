module.exports = (defaultState, actionNameToFunctionMap) =>
  function(state, action) {
    let fn;
    if (state == null) {
      return defaultState;
    } else if (fn = actionNameToFunctionMap[action.type]) {
      return fn(state, action);
    } else {
      return state;
    }
  }
;

module.exports = (defaultState, actionNameToFunctionMap) ->
  return (state, action) ->
    if not state?
      return defaultState
    else if fn = actionNameToFunctionMap[action.type]
      return fn(state, action.payload)
    else
      return state

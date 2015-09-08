# defaultState might make sense to pull from persistence rather
# than to have it pushed.
module.exports = (defaultState, actionNameToFunctionMap) ->
  return (state, action) ->
    if not state?
      return defaultState
    else if fn = actionNameToFunctionMap[action.type]
      return fn(state, action)
    else
      return state

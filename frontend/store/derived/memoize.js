_ = require 'lodash'

module.exports = (fn) ->
  lastArg    = null
  lastResult = null

  return (arg) ->
    if _.all arg, ((value, key) -> lastArg?[key] == value)
      return lastResult
    else
      lastArg = arg
      lastResult = fn arg
      return lastResult

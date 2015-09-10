_ = require 'lodash'

select = require './select'

DERIVED_FUNCTIONS_BY_NAME = {
  # Due to Browserify, these can't be dynamic requires. SADFACE.
  searchedGroupedIngredients : require './searchedGroupedIngredients'
  computeMixabilityForAll    : require './computeMixabilityForAll'
  mixabilityByRecipeId       : require './mixabilityByRecipeId'
  filteredGroupedRecipes     : require './filteredGroupedRecipes'
  computeMixabilityForAll    : require './computeMixabilityForAll'
}

destructuringMemoizedFunctions = _.mapValues DERIVED_FUNCTIONS_BY_NAME, (fn, fnName) ->
  lastArg    = null
  lastResult = null

  return (state) ->
    arg = select state, fn.stateSelector
    if _.all arg, ((value, key) -> lastArg?[key] == value)
      return lastResult
    else
      lastArg = arg
      lastResult = fn(arg)
      return lastResult

module.exports = destructuringMemoizedFunctions

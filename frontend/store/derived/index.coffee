_ = require 'lodash'

select = require './select'

FUNCTIONS_BY_NAME = {
  # Due to Browserify, these can't be dynamic requires. SADFACE.
  computeMixabilityForAll    : require './computeMixabilityForAll'
  filteredGroupedRecipes     : require './filteredGroupedRecipes'
  mixabilityByRecipeId       : require './mixabilityByRecipeId'
  searchedGroupedIngredients : require './searchedGroupedIngredients'
}

module.exports = _.mapValues FUNCTIONS_BY_NAME, (fn) ->
  return (state) -> fn.memoized select(state, fn.stateSelector)

_ = require 'lodash'

# These two should probably be memoized functions, but because they're really
# just set once at the beginning I'm gonna ignore it for now.
_recomputeDerivedLists = (state) ->
  allRecipes = state.customRecipes.concat state.defaultRecipes
  return _.defaults {
    allRecipes
    alphabeticalRecipes : _.sortBy allRecipes, 'sortName'
  }, state

module.exports = require('./makeReducer') {
  allRecipes          : []
  defaultRecipes      : []
  customRecipes       : []
  alphabeticalRecipes : []
}, {
  'set-default-recipes' : (state, { recipes }) ->
    return _recomputeDerivedLists _.defaults({ defaultRecipes : recipes}, state)

  'set-custom-recipes' : (state, { recipes }) ->
    return _recomputeDerivedLists _.defaults({ customRecipes : recipes}, state)

  'save-recipe' : (state, { recipe }) ->
    return _recomputeDerivedLists _.defaults({
      customRecipes : state.customRecipes.concat [ recipe ]
    }), state

  'delete-recipe' : (state, { recipeId }) ->
    return _recomputeDerivedLists _.defaults({
      customRecipes : _.reject state.customRecipes, { recipeId }
    }), state

}

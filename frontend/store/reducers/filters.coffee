_ = require 'lodash'

{ ANY_BASE_LIQUOR } = require '../../../shared/definitions'

module.exports = require('./makeReducer') _.extend({
  recipeSearchTerm       : ''
  ingredientSearchTerm   : ''
  selectedIngredientTags : {}
  baseLiquorFilter       : ANY_BASE_LIQUOR
  includeAllDrinks       : true
}, require('../persistence').load().filters), {
  'set-recipe-search-term' : (state, { searchTerm }) ->
    return _.defaults { recipeSearchTerm : searchTerm }, state

  'set-ingredient-search-term' : (state, { searchTerm }) ->
    return _.defaults { ingredientSearchTerm : searchTerm }, state

  'set-selected-ingredient-tags' : (state, { tags }) ->
    return _.defaults { selectedIngredientTags : tags }, state

  'set-base-liquor-filter' : (state, { filter }) ->
    return _.defaults { baseLiquorFilter : filter }, state

  'set-include-all-drinks' : (state, { include }) ->
    return _.defaults { includeAllDrinks : include }, state
}

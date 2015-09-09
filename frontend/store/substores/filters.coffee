{ ANY_BASE_LIQUOR } = require '../../../shared/definitions'

module.exports = require('./makeReducer') {
  recipeSearchTerm       : ''
  ingredientSearchTerm   : ''
  selectedIngredientTags : {}
  baseLiquorFilter       : ANY_BASE_LIQUOR
  mixabilityFilters      :
    mixable          : true
    nearMixable      : true
    notReallyMixable : true
}, {
  'set-recipe-search-term' : (state, { searchTerm }) ->
    return _.defaults { recipeSearchTerm : searchTerm }, state

  'set-ingredient-search-term' : (state, { searchTerm }) ->
    return _.defaults { ingredientSearchTerm : searchTerm }, state

  'set-selected-ingredient-tags' : (state, { tags }) ->
    return _.defaults { selectedIngredientTags : tags }, state

  'set-base-liquor-filter' : (state, { filter }) ->
    return _.defaults { baseLiquorFilter : filter }, state

  'set-mixability-filters' : (state, { filters }) ->
    return _.defaults {
      mixabilityFilters : _.pick filters, _.keys(state.mixabilityFilters)
    }, state
}

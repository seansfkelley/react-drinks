log = require 'loglevel'

normalization       = require '../../shared/normalization'
{ ANY_BASE_LIQUOR } = require '../../shared/definitions'

_computeIngredientsByTag = (groupedIngredients, intangibleIngredients) ->
  ingredients = _.chain groupedIngredients
    .pluck 'ingredients'
    .flatten()
    .value()

  ingredientsByTag = _.chain ingredients
    .filter (i) -> i.tag?
    .reduce ((map, i) -> map[i.tag] = i ; return map), {}
    .value()

  for i in intangibleIngredients
    ingredientsByTag[i.tag] = i
    ingredients.push i

  for i in ingredients
    if i.generic? and not ingredientsByTag[i.generic]?
      log.trace "ingredient #{i.tag} refers to unknown generic #{i.generic}; inferring generic"
      ingredientsByTag[i.generic] = normalization.normalizeIngredient {
        tag     : i.generic
        display : "[inferred] #{i.generic}"
      }

  return ingredientsByTag

module.exports = require('./makeReducer') {
  alphabeticalIngredients    : []
  allAlphabeticalIngredients : []
  groupedIngredients         : []
  ingredientsByTag           : {}
}, {
  'set-ingredients' : (state, { groupedIngredients, intangibleIngredients, alphabeticalIngredientTags }) ->
    # We don't use state, this is a set-once kind of deal.

    ingredientsByTag           = _computeIngredientsByTag groupedIngredients, intangibleIngredients
    allAlphabeticalIngredients = _.map alphabeticalIngredientTags, (t) -> ingredientsByTag[t]
    alphabeticalIngredients    = _.filter allAlphabeticalIngredients, 'tangible'

    return {
      alphabeticalIngredients
      allAlphabeticalIngredients
      groupedIngredients
      ingredientsByTag
    }
}

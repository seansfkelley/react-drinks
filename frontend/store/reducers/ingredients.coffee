_   = require 'lodash'
log = require 'loglevel'

normalization       = require '../../../shared/normalization'
{ ANY_BASE_LIQUOR } = require '../../../shared/definitions'

_displaySort = (i) -> i.display.toLowerCase()

_computeIngredientsByTag = (ingredients, intangibleIngredients) ->
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

_computeGroupedIngredients = (ingredients, groups) ->
  return _.chain ingredients
    .filter 'tangible'
    .sortBy _displaySort
    .groupBy 'group'
    .map (ingredients, groupTag) ->
      return {
        name : _.findWhere(groups, { type : groupTag }).display
        ingredients
      }
    .sortBy ({ name }) -> _.findIndex groups, { display : name }
    .value()

module.exports = require('./makeReducer') _.extend({
  alphabeticalIngredients    : []
  allAlphabeticalIngredients : []
  groupedIngredients         : []
  ingredientsByTag           : {}
}, require('../persistence').load().ingredients), {
  'set-ingredients' : (state, { ingredients, groups }) ->
    # We don't use state, this is a set-once kind of deal.
    return {
      allAlphabeticalIngredients : _.sortBy ingredients, _displaySort
      alphabeticalIngredients    : _.sortBy _.filter(ingredients, 'tangible'), _displaySort
      ingredientsByTag           : _computeIngredientsByTag ingredients, _.reject(ingredients, 'tangible')
      groupedIngredients         : _computeGroupedIngredients ingredients, groups
    }
}

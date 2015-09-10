_ = require 'lodash'

assert = require '../../../shared/tinyassert'

searchedGroupedIngredients = ({ groupedIngredients, ingredientSearchTerm }) ->
  ingredientSearchTerm ?= ''

  assert groupedIngredients

  if (ingredientSearchTerm.trim() ? '') == ''
    return groupedIngredients
  else
    ingredientSearchTerm = ingredientSearchTerm.toLowerCase()

    filterBySearchTerm = (i) ->
      for term in i.searchable
        if term.indexOf(ingredientSearchTerm) != -1
          return true
      return false

    return _.chain groupedIngredients
      .map ({ name, ingredients }) ->
        ingredients = _.filter ingredients, filterBySearchTerm
        return { name, ingredients }
      .filter ({ ingredients }) -> ingredients.length > 0
      .value()

module.exports = _.extend searchedGroupedIngredients, {
  stateSelector :
    groupedIngredients   : 'ingredients.groupedIngredients'
    ingredientSearchTerm : 'filters.ingredientSearchTerm'
}

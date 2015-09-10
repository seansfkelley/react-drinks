_ = require 'lodash'

assert = require '../../../shared/tinyassert'

searchedGroupedIngredients = ({ groupedIngredients, searchTerm }) ->
  searchTerm ?= ''

  assert groupedIngredients

  if (searchTerm.trim() ? '') == ''
    return groupedIngredients
  else
    searchTerm = searchTerm.toLowerCase()

    filterBySearchTerm = (i) ->
      for term in i.searchable
        if term.indexOf(searchTerm) != -1
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
    groupedIngredients : 'ingredients.groupedIngredients'
    searchTerm         : 'filters.ingredientSearchTerm'
}

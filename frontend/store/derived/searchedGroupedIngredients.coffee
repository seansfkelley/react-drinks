_ = require 'lodash'

searchedGroupedIngredients = ({ groupedIngredients, ingredientSearchTerm }) ->
  if (ingredientSearchTerm?.trim() ? '') == ''
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

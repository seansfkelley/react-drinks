_ = require 'lodash'

{ ALPHABETICAL_INGREDIENTS, GROUPED_INGREDIENTS } = require '../backend/ingredients'

module.exports = {
  method  : 'get'
  route   : '/ingredients'
  handler : (req, res) ->
    res.json {
      groupedIngredients         : GROUPED_INGREDIENTS
      intangibleIngredients      : _.reject ALPHABETICAL_INGREDIENTS, 'tangible'
      alphabeticalIngredientTags : _.pluck ALPHABETICAL_INGREDIENTS, 'tag'
    }
}

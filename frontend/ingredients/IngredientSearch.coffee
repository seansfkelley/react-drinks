_ = require 'lodash'

class IngredientSearch
  constructor : (@_ingredients) ->

  guess : (s) ->
    if not s or not s.trim().length
      return null

    s = s.trim().toLowerCase()

    return _.chain @_ingredients
      .filter ({ tag, searchable }) ->
        if tag.indexOf(s) != -1
          return true
        return _.any searchable, (term) -> term.indexOf(s) != -1
      .sortBy ({ tangible }, i) -> if not tangible then 0 else i + 1
      .first()
      .value()

  @filterIngredient : (i, term) ->
    term = term?.trim().toLowerCase()
    if not term
      return false
    else
      return _.any i.searchable, (s) -> s.indexOf(term) != -1

module.exports = IngredientSearch

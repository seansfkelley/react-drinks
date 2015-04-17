_ = require 'lodash'

class IngredientGuesser
  constructor : (@_ingredients) ->

  guess : (s) ->
    if not s or not s.trim().length
      return null

    s = s.trim()

    return _.chain @_ingredients
      .filter ({ tag, searchable }) ->
        if tag.indexOf(s) != -1
          return true
        return _.any searchable, (term) -> term.indexOf(s) != -1
      .sortBy ({ tangible }, i) -> if not tangible then 0 else i + 1
      .first()
      .value()

module.exports = IngredientGuesser

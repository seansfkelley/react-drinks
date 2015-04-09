_ = require 'lodash'

class IngredientGuesser
  constructor : (@_ingredients) ->

  guess : (s) ->
    if not s or not s.trim().length
      return null

    for i in @_ingredients
      if i.tag.indexOf(s) != -1
        return i
    return null

module.exports = IngredientGuesser

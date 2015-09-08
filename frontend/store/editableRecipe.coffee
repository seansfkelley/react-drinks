{ ANY_BASE_LIQUOR } = require '../../shared/definitions'

COUNT_REGEX = /^[-. \/\d]+/

MEASUREMENTS = [
  'ml'
  'cl'
  'l'
  'liter'
  'oz'
  'ounce'
  'pint'
  'part'
  'shot'
  'tsp'
  'teaspoon'
  'tbsp'
  'tablespoon'
  'cup'
  'bottle'
  'barspoon'
  'dash'
  'dashes'
  'drop'
  'pinch'
  'pinches'
  'slice'
]

_parseIngredient : (rawText, tag) ->
  text = rawText.trim()

  if match = COUNT_REGEX.exec text
    displayAmount = match[0]
    text = text[displayAmount.length..].trim()

  possibleUnit = text.split(' ')[0]
  if possibleUnit in MEASUREMENTS or _.any(MEASUREMENTS, (m) -> possibleUnit == m + 's')
    displayUnit = possibleUnit
    text = text[displayUnit.length..].trim()

  displayIngredient = text

  return {
    raw       : rawText
    isEditing : false
    tag       : tag
    display   : _.pick { displayAmount, displayUnit, displayIngredient }, _.identity
  }

_createEmptyStore = -> {
  name         : ''
  ingredients  : []
  instructions : ''
  notes        : ''
  base         : []
}

module.exports = require('./makeReducer') _createEmptyStore(), {
  'set-name' : (state, { name }) ->
    return _.defaults { name }, state

  'delete-ingredient' : (state, { index }) ->
    ingredients = _.clone state.ingredients
    # Ugh side effects.
    ingredients.splice index, 1
    return _.defaults { ingredients }, state

  'add-ingredient' : (state) ->
    return _.defaults {
      ingredients : state.ingredients.concat [{ isEditing : true }]
    }, state

  'commit-ingredient' : (state, { index, rawText, tag }) ->
    ingredients = _.clone state.ingredients
    ingredients[index] = _parseIngredient rawText, tag
    return _.defaults { ingredients }, state

  'set-instructions' : (state, { instructions }) ->
    return _.defaults { instructions }, state

  'set-notes' : (state, { notes }) ->
    return _.defaults { notes }, state

  'toggle-base-liquor-tag' : (state, { tag }) ->
    if tag in state.base
      return _.without state.base, tag
    else
      return state.base.concat [ tag ]

  'save-recipe' : (state) ->
    return _createEmptyStore()

  'clear-editable-recipe' : (state) ->
    return _createEmptyStore()
}

_ = require 'lodash'

ASCII_TO_ENTITY = {
  '1/4' : '\u00bc'
  '1/2' : '\u00bd'
  '3/4' : '\u00be'
  '1/8' : '\u215b'
  '3/8' : '\u215c'
  '5/8' : '\u215d'
  '7/8' : '\u215e'
  '1/3' : '\u2153'
  '2/3' : '\u2154'
}
ENTITY_TO_ASCII = _.invert ASCII_TO_ENTITY

ASCII_FRACTION_REGEX  = new RegExp _.keys(ASCII_TO_ENTITY).join('|'), 'g'
ENTITY_FRACTION_REGEX = new RegExp _.keys(ENTITY_TO_ASCII).join('|'), 'g'

fractionify = (s) ->
  return s?.replace(ASCII_FRACTION_REGEX, (m) -> ASCII_TO_ENTITY[m])

defractionify = (s) ->
  return s?.replace(ENTITY_FRACTION_REGEX, (m) -> ENTITY_TO_ASCII[m])

# This does not account for fractionified strings!
MEASURE_AMOUNT_REGEX = /^(\d[- \/\d]*)(.*)$/

splitMeasure = (s) ->
  s = s?.trim()
  if match = MEASURE_AMOUNT_REGEX.exec(s)
    return {
      measure : match[1].trim()
      unit    : match[2].trim()
    }
  else
    return { unit : s ? '' }

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

# TODO: Unit tests.
parseIngredientFromText = (rawText) ->
  text = rawText.trim()

  if match = COUNT_REGEX.exec text
    displayAmount = match[0]
    text = text[displayAmount.length..].trim()

  possibleUnit = text.split(' ')[0]
  if possibleUnit in MEASUREMENTS or _.any(MEASUREMENTS, (m) -> possibleUnit == m + 's')
    displayUnit = possibleUnit
    text = text[displayUnit.length..].trim()

  displayIngredient = text

  return _.pick { displayAmount, displayUnit, displayIngredient }, _.identity

# TODO: Unit tests.
parsePartialRecipeFromText = (rawText) ->
  [ rawName, rawIngredients, instructions, notes ] = _.invoke rawText.replace(/\n\n+/g, '\n\n').split('\n\n'), 'trim'

  if not rawName
    return {}

  name = _.chain rawName
      .split ' '
      .invoke 'trim'
      .compact()
      .map _.capitalize
      .join ' '
      .value()

  if not rawIngredients
    return { name }

  ingredients = _.map rawIngredients.split('\n'), parseIngredientFromText

  return { name, ingredients, instructions, notes }

module.exports = {
  fractionify
  defractionify
  splitMeasure
  parseIngredientFromText
  parsePartialRecipeFromText
}

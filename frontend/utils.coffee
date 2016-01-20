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

COUNT_REGEX = /^[-. \/\d]+/

MEASUREMENTS = _.chain [
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
  'scoop'
  'leaf'
  'leaves'
  'sprig'
]
.map (unit) -> [ unit, unit + 's' ]
.flatten()
.uniq()
.value()

parseIngredientFromText = (rawText) ->
  if not rawText
    return {}

  text = rawText.trim()

  if match = COUNT_REGEX.exec text
    displayAmount = match[0].trim()
    text = text[displayAmount.length..].trim()

  possibleUnit = text.split(' ')[0]
  if possibleUnit in MEASUREMENTS
    displayUnit = possibleUnit.trim()
    text = text[displayUnit.length..].trim()

  displayIngredient = text

  return _.pick { displayAmount, displayUnit, displayIngredient }, _.identity

parsePartialRecipeFromText = (rawText) ->
  if not rawText?.trim()
    return {}

  [ rawName, rawIngredients, instructions, notes ] = _.invoke rawText.replace(/\n\n+/g, '\n\n').split('\n\n'), 'trim'

  name = _.chain rawName
      .split /\s+/
      .invoke 'trim'
      .compact()
      .map _.capitalize
      .join ' '
      .value()

  if not rawIngredients
    return { name }

  ingredients = _.map rawIngredients.split('\n'), parseIngredientFromText

  return _.pick { name, ingredients, instructions, notes }, _.identity

module.exports = {
  fractionify
  defractionify
  parseIngredientFromText
  parsePartialRecipeFromText
}

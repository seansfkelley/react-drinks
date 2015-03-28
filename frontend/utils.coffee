_ = require 'lodash'

ASCII_TO_ENTITIY = {
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
ENTITY_TO_ASCII = _.invert ASCII_TO_ENTITIY

ASCII_FRACTION_REGEX  = new RegExp _.keys(ASCII_TO_ENTITIY).join('|'), 'g'
ENTITY_FRACTION_REGEX = new RegExp _.keys(ENTITY_TO_ASCII).join('|'), 'g'

fractionify = (s) ->
  return s?.replace(ASCII_FRACTION_REGEX, (m) -> ASCII_TO_ENTITIY[m])

defractionify = (s) ->
  return s?.replace(ENTITY_FRACTION_REGEX, (m) -> ENTITY_TO_ASCII[m])

# This does not account for fractionified strings!
MEASURE_AMOUNT_REGEX = /^(\d[- \/\d]+)(.*)$/

splitMeasure = (s) ->
  s = s?.trim()
  if match = MEASURE_AMOUNT_REGEX.exec(s)
    return {
      measure : match[1].trim()
      unit    : match[2].trim()
    }
  else
    return { unit : s ? '' }

module.exports = { fractionify, defractionify, splitMeasure }

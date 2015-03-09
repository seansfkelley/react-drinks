_ = require 'lodash'

HTML_FRACTIONS =
  '1/4' : '\u00bc'
  '1/2' : '\u00bd'
  '3/4' : '\u00be'
  '1/8' : '\u215b'
  '3/8' : '\u215c'
  '5/8' : '\u215d'
  '7/8' : '\u215e'
  '1/3' : '\u2153'
  '2/3' : '\u2154'

ALL_FRACTION_REGEX = new RegExp _.keys(HTML_FRACTIONS).join('|'), 'g'

fractionify = (s) -> s.replace(ALL_FRACTION_REGEX, (m) -> HTML_FRACTIONS[m])

module.exports = { fractionify }

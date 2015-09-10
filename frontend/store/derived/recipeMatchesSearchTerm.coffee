_ = require 'lodash'

WHITESPACE_REGEX = /\s+/g

# SO INEFFICIENT.
recipeMatchesSearchTerm = ({ recipe, searchTerm, ingredientsByTag }) ->
  if not searchTerm?.trim()
    return false

  terms = _.compact searchTerm.trim().split(WHITESPACE_REGEX)

  searchable = _.chain recipe.ingredients
    .pluck 'tag'
    .map (t) => ingredientsByTag[t]?.searchable
    .compact()
    .flatten()
    .concat recipe.canonicalName.split(WHITESPACE_REGEX)
    .value()

  return _.all terms, (t) -> _.any(searchable, (s) -> s.indexOf(t) != -1)

module.exports = recipeMatchesSearchTerm

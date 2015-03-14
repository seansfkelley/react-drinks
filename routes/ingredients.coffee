_           = require 'lodash'
fs          = require 'fs'
yaml        = require 'js-yaml'
revalidator = require 'revalidator'

revalidatorUtils = require './revalidator-utils'
{ REQUIRED_STRING, OPTIONAL_STRING } = revalidatorUtils

INGREDIENT_SCHEMA = {
  type       : 'object'
  properties :
    # The display name of the ingredient.
    display : REQUIRED_STRING
    # The category this ingredient is in (e.g., spirit, mixer, syrup...)
    group : REQUIRED_STRING
    # The uniquely identifying tag for this ingredient. Defaults to the lowercase display name.
    tag : OPTIONAL_STRING
    # The tag for the generic (substitutable) ingredient for this ingredient. If the target doesn't
    # exist, a new invisible ingredient is added.
    generic : OPTIONAL_STRING
    # An array of searchable terms for the ingredient. Includes the display name of itself and its
    # generic (if it exists) by default.
    searchable :
      type     : 'array'
      required : false
      items :
        type : 'string'
}

GROUPS      = yaml.safeLoad fs.readFileSync(__dirname + '/../data/groups.yaml')
INGREDIENTS = yaml.safeLoad fs.readFileSync(__dirname + '/../data/ingredients.yaml')

console.log "loaded #{INGREDIENTS.length} ingredients in #{GROUPS.length} groups"

revalidatorUtils.validateOrThrow INGREDIENTS, {
  type  : 'array'
  items : INGREDIENT_SCHEMA
}

for i in INGREDIENTS
  i.tag        ?= i.display.toLowerCase()
  i.searchable ?= []
  # TODO: Should run this and the search terms through a Unicode canonicalization, e.g,
  # replace the non-ASCII characters with their equivalents.
  if not _.contains i.searchable, i.display.toLowerCase()
    i.searchable.push i.display.toLowerCase()
  # TODO: Add display for generic to here.
  # if i.generic and not _.contains i.searchable, i.generic
  #   i.searchable.push i.generic

GROUPED = _.chain INGREDIENTS
  .sortBy (i) -> i.display.toLowerCase()
  .groupBy 'group'
  .map (ingredients, groupTag) ->
    return {
      name : _.findWhere(GROUPS, { type : groupTag }).display
      ingredients
    }
  .sortBy ({ name }) -> _.findIndex GROUPS, { display : name }
  .value()

module.exports = {
  method  : 'get'
  route   : '/ingredients'
  handler : (req, res) -> res.json GROUPED
}

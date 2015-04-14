_           = require 'lodash'
fs          = require 'fs'
yaml        = require 'js-yaml'
revalidator = require 'revalidator'
log         = require 'loglevel'

normalization   = require '../shared/normalization'
revalidatorUtils = require './revalidator-utils'
{ REQUIRED_STRING, OPTIONAL_STRING } = revalidatorUtils

xor = (a, b) -> (a or b) and not (a and b)

INGREDIENT_SCHEMA = {
  type       : 'object'
  properties :
    # The display name of the ingredient.
    display : REQUIRED_STRING
    # The category this ingredient is in (e.g., spirit, mixer, syrup...)
    group :
      type    : 'string'
      conform : (v, object) -> xor(v?, not (object.tangible ? true))
    tangible :
      type    : 'boolean'
      conform : (v, object) -> xor(not (v ? true), object.group?)
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

log.info "loaded #{INGREDIENTS.length} ingredients in #{GROUPS.length} groups"

revalidatorUtils.validateOrThrow INGREDIENTS, {
  type  : 'array'
  items : INGREDIENT_SCHEMA
}

INGREDIENTS = _.chain INGREDIENTS
  .map normalization.normalizeIngredient
  .sortBy 'display'
  .value()

GROUPED = _.chain INGREDIENTS
  .filter 'tangible'
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
  handler : (req, res) ->
    res.json {
      groupedIngredients         : GROUPED
      alphabeticalIngredientTags : _.pluck INGREDIENTS, 'tag'
    }
}

_           = require 'lodash'
fs          = require 'fs'
yaml        = require 'js-yaml'
revalidator = require 'revalidator'

INGREDIENT_SCHEMA = {
  type  : 'array'
  items :
    type       : 'object'
    properties :
      # The display name of the ingredient.
      display :
        type      : 'string'
        required  : true
        minLength : 1
      # The category this ingredient is in (e.g., spirit, mixer, syrup...)
      group :
        type      : 'string'
        required  : true
        minLength : 1
      # The uniquely identifying tag for this ingredient. Defaults to the lowercase display name.
      tag :
        type      : 'string'
        required  : true
        minLength : 1
      # The tag for the generic (substitutable) ingredient for this ingredient. If the target doesn't
      # exist, a new invisible ingredient is added.
      generic :
        type      : 'string'
        required  : false
        minLength : 1
      # An array of searchable terms for the ingredient. Includes the display name of itself and its
      # generic (if it exists) by default.
      searchable :
        type     : 'array'
        required : true
        items :
          type      : 'string'
          minLength : 1
}

GROUPS      = yaml.safeLoad fs.readFileSync(__dirname + '/../data/groups.yaml')
INGREDIENTS = yaml.safeLoad fs.readFileSync(__dirname + '/../data/ingredients.yaml')
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

validation = revalidator.validate INGREDIENTS, INGREDIENT_SCHEMA
if not validation.valid
  throw new Error 'validation failed ' + JSON.stringify(validation.errors)

ALPHABETICAL = _.sortBy INGREDIENTS, (i) -> i.display.toLowerCase()

GROUPED = _.chain ALPHABETICAL
  .groupBy 'group'
  .map (ingredients, groupTag) ->
    name = GROUPS[groupTag].join ' > '
    return {
      name
      ingredients
    }
  .sortBy 'name'
  .value()

module.exports = {
  method  : 'get'
  route   : '/ingredients'
  handler : (req, res) -> res.json {
    alphabetical : ALPHABETICAL
    grouped      : GROUPED
  }
}

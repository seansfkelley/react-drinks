_           = require 'lodash'
fs          = require 'fs'
yaml        = require 'js-yaml'
revalidator = require 'revalidator'

INGREDIENT_SCHEMA = {
  type  : 'array'
  items :
    type       : 'object'
    properties :
      display :
        type      : 'string'
        required  : true
        minLength : 1
      group :
        type      : 'string'
        required  : true
        minLength : 1
      tag :
        type      : 'string'
        required  : true
        minLength : 1
      generic :
        type      : 'string'
        required  : false
        minLength : 1
}

GROUPS      = yaml.safeLoad fs.readFileSync(__dirname + '/../data/groups.yaml')
INGREDIENTS = yaml.safeLoad fs.readFileSync(__dirname + '/../data/ingredients.yaml')
for i in INGREDIENTS
  i.tag ?= i.display.toLowerCase()

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

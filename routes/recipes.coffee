_           = require 'lodash'
fs          = require 'fs'
yaml        = require 'js-yaml'
revalidator = require 'revalidator'

revalidatorUtils = require './revalidator-utils'
{ REQUIRED_STRING, OPTIONAL_STRING } = revalidatorUtils

RECIPE_SCHEMA = {
  type       : 'object'
  properties :
    # The display name of the recipe.
    name : REQUIRED_STRING
    # The measured ingredients for how to mix this recipe.
    ingredients :
      type       : 'array'
      required   : true
      properties :
        tag               : REQUIRED_STRING
        displayMeasure    : REQUIRED_STRING
        displayIngredient : REQUIRED_STRING
    # A string of one or more lines explaining how to make the drink.
    instructions : REQUIRED_STRING
    # A string of one or more lines with possibly interesting suggestions or historical notes.
    notes : OPTIONAL_STRING
    # The display name for the source of this recipe.
    source : OPTIONAL_STRING
    # The full URL to the source page for this recipe.
    url : OPTIONAL_STRING
}

RECIPES = _.sortBy yaml.safeLoad(fs.readFileSync(__dirname + '/../data/recipes.yaml')), 'name'

revalidatorUtils.validateOrThrow RECIPES, {
  type  : 'array'
  items : RECIPE_SCHEMA
}

for r in RECIPES
  r.normalizedName = r.name.toLowerCase().replace('/ /g', '-').replace(/[^-a-z0-9]/g, '')

module.exports = {
  method  : 'get'
  route   : '/recipes'
  handler : (req, res) -> res.json RECIPES
}

_           = require 'lodash'
fs          = require 'fs'
yaml        = require 'js-yaml'
revalidator = require 'revalidator'
log         = require 'loglevel'

latinize         = require '../shared/latinize'
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
      items      :
        properties :
          tag               : OPTIONAL_STRING
          displayAmount     :
            type     : 'string'
            required : false
            pattern  : /(\d+([- \/]\d+)?)+/
          displayUnit       : OPTIONAL_STRING
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

IBA_RECIPES   = yaml.safeLoad(fs.readFileSync(__dirname + '/../data/iba-recipes.yaml'))
OTHER_RECIPES = yaml.safeLoad(fs.readFileSync(__dirname + '/../data/recipes.yaml'))

RECIPES = _.sortBy IBA_RECIPES.concat(OTHER_RECIPES), 'name'

log.info "loaded #{RECIPES.length} recipes"

revalidatorUtils.validateOrThrow RECIPES, {
  type  : 'array'
  items : RECIPE_SCHEMA
}

for r in RECIPES
  r.searchableName = latinize(r.name).toLowerCase()
  r.normalizedName = r.searchableName.replace('/ /g', '-').replace(/[^-a-z0-9]/g, '')

module.exports = {
  method  : 'get'
  route   : '/recipes'
  handler : (req, res) -> res.json RECIPES
}

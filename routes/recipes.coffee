_           = require 'lodash'
fs          = require 'fs'
yaml        = require 'js-yaml'
revalidator = require 'revalidator'
log         = require 'loglevel'

normalization    = require '../shared/normalization'
revalidatorUtils = require './revalidator-utils'
{ REQUIRED_STRING, OPTIONAL_STRING } = revalidatorUtils

BASE_LIQUORS = [ 'gin', 'vodka', 'rum', 'whiskey', 'tequila', 'brandy', 'wine', 'liqueur', 'UNASSIGNED' ]

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
    # One of a few very broad ingredient categories that best describes the genre of this drink.
    base :
      type     : [ 'array', 'string' ]
      required : true
      conform  : (strOrArray) ->
        if _.isString strOrArray
          return strOrArray in BASE_LIQUORS
        else if _.isArray strOrArray
          return _.all strOrArray, (base) -> base in BASE_LIQUORS
        else
          return false
}

IBA_RECIPES   = yaml.safeLoad(fs.readFileSync(__dirname + '/../data/iba-recipes.yaml'))
OTHER_RECIPES = yaml.safeLoad(fs.readFileSync(__dirname + '/../data/recipes.yaml'))

RECIPES = _.sortBy IBA_RECIPES.concat(OTHER_RECIPES), 'name'

log.info "loaded #{RECIPES.length} recipes"

unassignedBases = _.where RECIPES, { base : 'UNASSIGNED' }
if unassignedBases.length
  log.warn "#{unassignedBases.length} recipes have an unassigned base liquor: #{_.pluck(unassignedBases, 'name').join ', '}"

revalidatorUtils.validateOrThrow RECIPES, {
  type  : 'array'
  items : RECIPE_SCHEMA
}

RECIPES = _.map RECIPES, normalization.normalizeRecipe

module.exports = {
  method  : 'get'
  route   : '/recipes'
  handler : (req, res) -> res.json RECIPES
}

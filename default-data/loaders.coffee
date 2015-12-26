_           = require 'lodash'
fs          = require 'fs'
yaml        = require 'js-yaml'
revalidator = require 'revalidator'
log         = require 'loglevel'

normalization = require '../shared/normalization'
definitions   = require '../shared/definitions'

revalidatorUtils = require './revalidator-utils'
{ REQUIRED_STRING, OPTIONAL_STRING } = revalidatorUtils

BASE_LIQUORS = [ definitions.UNASSIGNED_BASE_LIQUOR ].concat definitions.BASE_LIQUORS

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
            pattern  : /^[-. \/\d]+$/
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

loadRecipeFile = _.memoize (filename) ->
  log.debug "loading recipes from #{filename}"
  recipes = yaml.safeLoad fs.readFileSync("#{__dirname}/data/#{filename}.yaml")
  log.debug "loaded #{recipes.length} recipe(s) from #{filename}"

  unassignedBases = _.where recipes, { base : definitions.UNASSIGNED_BASE_LIQUOR }
  if unassignedBases.length
    log.warn "#{unassignedBases.length} recipe(s) in #{filename} have an unassigned base liquor: #{_.pluck(unassignedBases, 'name').join ', '}"

  revalidatorUtils.validateOrThrow recipes, {
    type  : 'array'
    items : RECIPE_SCHEMA
  }

  return _.map recipes, normalization.normalizeRecipe

module.exports = { loadRecipeFile }

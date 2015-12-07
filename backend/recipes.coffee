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

RECIPE_FILES = [
  'iba-recipes'
  'recipes'
]

if '--custom-recipes' in process.argv
  RECIPE_FILES.push 'custom-recipes'
  RECIPE_FILES.push 'michael-cecconi'

RECIPES = _.chain RECIPE_FILES
  .map (f) -> yaml.safeLoad(fs.readFileSync("#{__dirname}/../data/#{f}.yaml"))
  .flatten()
  .sortBy 'sortName'
  .value()

log.info "loaded #{RECIPES.length} recipes"

unassignedBases = _.where RECIPES, { base : definitions.UNASSIGNED_BASE_LIQUOR }
if unassignedBases.length
  log.warn "#{unassignedBases.length} recipes have an unassigned base liquor: #{_.pluck(unassignedBases, 'name').join ', '}"

revalidatorUtils.validateOrThrow RECIPES, {
  type  : 'array'
  items : RECIPE_SCHEMA
}

BUILTIN_RECIPES = _.map RECIPES, normalization.normalizeRecipe

savedCustomRecipes = []

save = (recipe) ->
  recipeId = { recipe }
  if not recipeId
    throw new Error('no recipeId provided')
  else if _.findWhere(BUILTIN_RECIPES, { recipeId }) or _.findWhere(savedCustomRecipes, { recipeId })
    throw new Error('recipeId conflicts with existing recipe, panic!')

load = (recipeId) ->

bulkLoad = (recipeIds) ->
  return []
    .concat _.filter(BUILTIN_RECIPES, ({ recipeId }) -> recipeId in recipeIds)
    .concat _.filter(savedCustomRecipes, ({ recipeId }) -> recipeId in recipeIds)

module.exports = {
  save
  load
  bulkLoad
  BUILTIN_RECIPES
}

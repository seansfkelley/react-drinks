_           = require 'lodash'
fs          = require 'fs'
yaml        = require 'js-yaml'
revalidator = require 'revalidator'
log         = require 'loglevel'
md5         = require 'MD5'

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

try
  savedCustomRecipes = require '../data/saved-custom-recipes.json'
catch
  savedCustomRecipes = {}

save = (recipe) ->
  { recipeId } = recipe
  console.log "attempting to save recipe with given ID '#{recipeId}'"

  while (not recipeId or _.findWhere(BUILTIN_RECIPES, { recipeId }) or _.findWhere(savedCustomRecipes, { recipeId }))
    console.log "given recipe ID '#{recipeId}' is missing or in use, randomly generating new one..."
    recipeId = md5 Math.random().toString()
    console.log "generated new recipe ID '#{recipeId}'"

  recipe = _.defaults { recipeId }, recipe

  savedCustomRecipes[recipeId] = recipe
  fs.writeFileSync './data/saved-custom-recipes.json', JSON.stringify(savedCustomRecipes), 'utf8'

  console.log "successfully saved new recipe with ID '#{recipeId}'"

  return recipeId

load = (recipeId) ->
  console.log "loading recipe with ID '#{recipeId}'"
  return BUILTIN_RECIPES[recipeId] ? savedCustomRecipes[recipeId] ? null

bulkLoad = (recipeIds) ->
  console.log "bulk-loading #{recipeIds.length} recipes"
  recipes = []
    .concat _.filter(BUILTIN_RECIPES, ({ recipeId }) -> recipeId in recipeIds)
    .concat _.filter(savedCustomRecipes, ({ recipeId }) -> recipeId in recipeIds)
  return _.indexBy recipes, 'recipeId'

module.exports = {
  save
  load
  bulkLoad
  BUILTIN_RECIPES
}

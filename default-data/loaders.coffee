_           = require 'lodash'
fs          = require 'fs'
yaml        = require 'js-yaml'
revalidator = require 'revalidator'
log         = require 'loglevel'

normalization = require '../shared/normalization'
definitions   = require '../shared/definitions'

revalidatorUtils = require './revalidator-utils'
{ REQUIRED_STRING, OPTIONAL_STRING } = revalidatorUtils

xor = (a, b) -> (a or b) and not (a and b)

BASE_LIQUORS = [ definitions.UNASSIGNED_BASE_LIQUOR ].concat definitions.BASE_LIQUORS

INGREDIENT_SCHEMA = {
  type       : 'object'
  properties :
    # The display name of the ingredient.
    display : REQUIRED_STRING
    # The category this ingredient is in (e.g., spirit, mixer, syrup...)
    group :
      type    : 'string'
      conform : (v, object) -> xor(v?, not (object.tangible ? true))
    # Intangible ingredients are useful to index on or specify, but are not specific enough to
    # warrant being something you can have in your cabinet. The canonical example is Chartreuse
    # (either variety), but it's also useful for e.g whiskey as a generic.
    tangible :
      type    : 'boolean'
      conform : (v, object) -> xor(not (v ? true), object.group?)
    # The uniquely identifying tag for this ingredient. Defaults to the lowercase display name.
    tag : OPTIONAL_STRING
    # The tag for the generic (substitutable) ingredient for this ingredient. If the target doesn't
    # exist, a new invisible ingredient is added.
    generic : OPTIONAL_STRING
    # An approximate rating for how difficult this ingredient is to buy.
    difficulty :
      type : 'string'
      enum : [ 'easy', 'medium', 'hard' ]
    # An array of searchable terms for the ingredient. Includes the display name of itself and its
    # generic (if it exists) by default.
    searchable :
      type     : 'array'
      required : false
      items :
        type : 'string'
}

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

loadIngredientGroups = _.once ->
  log.debug "loading ingredient grouping"
  groups = yaml.safeLoad fs.readFileSync("#{__dirname}/data/groups.yaml")
  log.debug "loaded #{groups.length} groups"

  # TODO: revalidator

  return groups

loadIngredients = _.once ->
  log.debug "loading ingredients"
  ingredients = yaml.safeLoad fs.readFileSync("#{__dirname}/data/ingredients.yaml")
  log.debug "loaded #{ingredients.length} ingredients"

  revalidatorUtils.validateOrThrow ingredients, {
    type  : 'array'
    items : INGREDIENT_SCHEMA
  }

  return _.map ingredients, normalization.normalizeIngredient


module.exports = {
  loadRecipeFile
  loadIngredientGroups
  loadIngredients
}

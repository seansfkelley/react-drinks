_ = require 'lodash'

recipes     = require './recipes'
ingredients = require './ingredients'

{ ALPHABETICAL_INGREDIENTS, GROUPED_INGREDIENTS } = ingredients

module.exports = [
  method  : 'get'
  route   : '/'
  handler : (req, res) ->
    recipes.getDefaultRecipeIds()
    .then (defaultRecipeIds) ->
      res.render 'app', { defaultRecipeIds }
,
  method  : 'get'
  route   : '/ingredients'
  handler : (req, res) ->
    res.json {
      groupedIngredients         : GROUPED_INGREDIENTS
      intangibleIngredients      : _.reject ALPHABETICAL_INGREDIENTS, 'tangible'
      alphabeticalIngredientTags : _.pluck ALPHABETICAL_INGREDIENTS, 'tag'
    }
,
  method  : 'post'
  route   : '/recipes/bulk'
  handler : (req, res) ->
    recipes.bulkLoad(req.body.recipeIds)
    .then (recipesById) ->
      res.json recipesById
,
  method  : 'get'
  route   : '/recipe/:recipeId'
  handler : (req, res) ->
    recipes.load(req.params.recipeId)
    .then (recipe) ->
      # TODO: Redirect to error page if this doesn't exist.
      res.render 'recipe', { recipe }
,
  method  : 'post'
  route   : '/recipe'
  handler : (req, res) ->
    recipe = req.body
    # This is actually already passed, but it's a string, and that seems bad,
    # so we might as well just set it unconditionally here.
    recipe.isCustom = true

    recipes.save(recipe)
    .then (ackRecipeId) ->
      res.json { ackRecipeId }
]

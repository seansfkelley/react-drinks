_ = require 'lodash'

recipes     = require './recipes'
ingredients = require './ingredients'

{ ALPHABETICAL_INGREDIENTS, GROUPED_INGREDIENTS } = ingredients

module.exports = [
  method  : 'get'
  route   : '/'
  handler : (req, res) ->
    res.render 'app', { defaultRecipeIds : _.pluck recipes.BUILTIN_RECIPES, 'recipeId' }
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
    res.json recipes.bulkLoad(req.body.recipeIds)
,
  method  : 'get'
  route   : '/recipe/:recipeId'
  handler : (req, res) ->
    # TODO: Redirect to error page if this doesn't exist.
    res.render 'recipe', { recipe : recipes.load req.params.recipeId }
,
  method  : 'post'
  route   : '/recipe'
  handler : (req, res) ->
    recipe = req.body
    # This is actually already passed, but it's a string, and that seems bad,
    # so we might as well just set it unconditionally here.
    recipe.isCustom = true
    recipes.save recipe
    res.send()
]

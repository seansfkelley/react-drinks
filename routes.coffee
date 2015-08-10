_ = require 'lodash'

RECIPES = require './backend/recipes'

{ ALPHABETICAL_INGREDIENTS, GROUPED_INGREDIENTS } = require './backend/ingredients'

module.exports = [
  method  : 'get'
  route   : '/'
  handler : (req, res) -> res.render 'app'
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
  method  : 'get'
  route   : '/recipes'
  handler : (req, res) -> res.json RECIPES
,
  method  : 'get'
  route   : '/recipe/:recipeId'
  handler : (req, res) ->
    # TODO: Redirect to error page if this doesn't exist.
    recipe = _.findWhere RECIPES, { recipeId : req.params.recipeId }
    res.render 'recipe', { recipe }
]

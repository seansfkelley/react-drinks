_       = require 'lodash'
recipes = _.cloneDeep require('../data/recipes')

recipes = _.sortBy recipes, 'name'

for r in recipes
  r.normalizedName = r.name.toLowerCase().replace('/ /g', '-').replace(/[^-a-z0-9]/g, '')
  _.chain r.ingredients
    .pluck 'tag'
    .compact()
    .uniq()
    .tap (tags) -> r.searchableIngredients = tags
    .value() # Lazy evaluation, must call.

module.exports = {
  method  : 'get'
  route   : '/recipes'
  handler : (req, res) -> res.json recipes
}

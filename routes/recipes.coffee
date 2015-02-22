_       = require 'lodash'
recipes = _.cloneDeep require('../data/recipes')

recipes = _.sortBy recipes, 'name'

for r in recipes
  r.normalizedName = r.name.toLowerCase().replace('/ /g', '-').replace(/[^-a-z0-9]/g, '')

module.exports = {
  method  : 'get'
  route   : '/recipes'
  handler : (req, res) -> res.json recipes
}

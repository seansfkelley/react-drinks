RECIPES = require '../backend/recipes'

module.exports = {
  method  : 'get'
  route   : '/recipes'
  handler : (req, res) -> res.json RECIPES
}

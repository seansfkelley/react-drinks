_           = require 'lodash'
ingredients = _.cloneDeep require('../data/ingredients')
groups      = require '../data/groups'

alphabetical = _.sortBy _.cloneDeep(ingredients), (i) -> i.display.toLowerCase()

for i in alphabetical
  i.tag ?= i.display.toLowerCase()

grouped = _.chain alphabetical
  .groupBy 'group'
  .map (ingredients, groupTag) ->
    name = groups[groupTag].join ' > '
    return {
      name
      ingredients
    }
  .sortBy 'name'
  .value()

module.exports = {
  method  : 'get'
  route   : '/ingredients'
  handler : (req, res) -> res.json {
    alphabetical
    grouped
  }
}

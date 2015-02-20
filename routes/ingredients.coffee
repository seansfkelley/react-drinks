_ = require 'lodash'

ingredients = _.sortBy require('../data/ingredients'), (i) -> i.display.toLowerCase()

for i in ingredients
  i.tag ?= i.display.toLowerCase()

module.exports = {
  method  : 'get'
  route   : '/ingredients'
  handler : (req, res) -> res.json ingredients
}

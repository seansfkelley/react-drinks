_ = require 'lodash'

ingredients = _.clone require('../data/ingredients')

for i in ingredients
  i.tag ?= i.display.toLowerCase()

module.exports = {
  method  : 'get'
  route   : '/ingredients'
  handler : (req, res) -> res.json ingredients
}

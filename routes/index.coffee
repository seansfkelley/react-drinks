_ = require 'lodash'

module.exports = _.flatten _.map [
  'main'
  'ingredients'
  'recipes'
], (filename) -> require "./#{filename}"

_ = require 'lodash'

module.exports = _.flatten _.map [
  'main'
  'ingredients'
], (filename) -> require "./#{filename}"

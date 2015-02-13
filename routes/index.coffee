module.exports = require('lodash').map [
  'main'
], (filename) -> require "./#{filename}"

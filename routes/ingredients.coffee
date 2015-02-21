_ = require 'lodash'

alphabetical = _.sortBy require('../data/ingredients'), (i) -> i.display.toLowerCase()

for i in alphabetical
  i.tag ?= i.display.toLowerCase()

grouped = _.groupBy alphabetical, 'group'

module.exports = {
  method  : 'get'
  route   : '/ingredients'
  handler : (req, res) -> res.json {
    alphabetical
    grouped
  }
}

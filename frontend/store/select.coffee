_ = require 'lodash'

module.exports = (state, pathsByField) ->
  return _.mapValues pathsByField, (path) ->
    return _.get state, path

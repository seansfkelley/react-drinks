_ = require 'lodash'

ClassNameMixin = {
  getClassName : (withDefault = '') ->
    return withDefault + ' ' + (@props.className ? '')
}

module.exports = ClassNameMixin

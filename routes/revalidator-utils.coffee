_           = require 'lodash'
revalidator = require 'revalidator'

_.extend revalidator.validate.defaults, {
  validateFormats          : true
  validateFormatsStrict    : true
  validateFormatExtensions : true
  additionalProperties     : false
  cast                     : false
}

module.exports = {
  REQUIRED_STRING :
    type     : 'string'
    required : true
  OPTIONAL_STRING :
    type     : 'string'
    required : false
  validateOrThrow : (object, schema) ->
    validation = revalidator.validate object, schema
    if not validation.valid
      throw new Error 'validation failed ' + JSON.stringify(validation.errors)
}

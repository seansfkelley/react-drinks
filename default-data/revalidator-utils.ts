const _ = require('lodash');
const util = require('util');
const revalidator = require('revalidator');

_.extend(revalidator.validate.defaults, {
  validateFormats: true,
  validateFormatsStrict: true,
  validateFormatExtensions: true,
  additionalProperties: false,
  cast: false
});

module.exports = {
  REQUIRED_STRING: {
    type: 'string',
    required: true
  },
  OPTIONAL_STRING: {
    type: 'string',
    required: false
  },
  validateOrThrow(object, schema) {
    const validation = revalidator.validate(object, schema);
    if (!validation.valid) {
      throw new Error(`validation failed: \n${ util.inspect(validation.errors) }`);
    }
  }
};


assert = (condition, message = null) ->
  if not condition
    throw new Error(message ? 'Assertion error')

module.exports = assert

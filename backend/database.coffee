_       = require 'lodash'
PouchDB = require 'pouchdb'
Promise = require 'bluebird'

FN_NAMES_TO_PROXY = [
  'get'
  'post'
  'put'
  'allDocs'
  'bulkDocs'
]

class PouchDbProxy
  constructor : (@_delegate) ->
    _.each FN_NAMES_TO_PROXY, (fnName) =>
      @[fnName] = @wrap @_delegate[fnName].bind(@_delegate)

class BluebirdPromisePouchDb extends PouchDbProxy
  wrap : (fn) -> (args...) ->
    return Promise.resolve fn(args...)

class RetryingPouchDb extends PouchDbProxy
  wrap : (fn) -> (args...) ->
    retryHelper = (retries) ->
      return fn(args...)
      .catch (e) ->
        if retries > 0
          return retryHelper(retries - 1)
        else
          throw e

    return retryHelper 1

get = _.once ->
  config = require './config'
  auth   = _.pick config.couchDb, 'username', 'password'
  if _.size(auth) == 2
    dbOptions = { auth }
  else
    dbOptions = {}

  return _.mapValues {
    recipeDb     : config.couchDb.url + config.couchDb.recipeDbName
    configDb     : config.couchDb.url + config.couchDb.configDbName
    ingredientDb : config.couchDb.url + config.couchDb.ingredientDbName
  }, (url) -> new RetryingPouchDb(new BluebirdPromisePouchDb(new PouchDB(url, dbOptions)))

module.exports = { get }

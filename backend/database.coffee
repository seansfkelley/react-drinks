_       = require 'lodash'
PouchDB = require 'pouchdb'

get = _.once ->
  config = require './config'
  auth   = _.pick config.couchDb, 'username', 'password'
  if _.size(auth) == 2
    dbOptions = { auth }
  else
    dbOptions = {}

  return {
    recipeDb     : new PouchDB config.couchDb.url + config.couchDb.recipeDbName, dbOptions
    configDb     : new PouchDB config.couchDb.url + config.couchDb.configDbName, dbOptions
    ingredientDb : new PouchDB config.couchDb.url + config.couchDb.ingredientDbName, dbOptions
  }

module.exports = { get }

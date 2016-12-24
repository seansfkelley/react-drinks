const _       = require('lodash');
const log     = require('loglevel');
const PouchDB = require('pouchdb');
const Promise = require('bluebird');

const FN_NAMES_TO_PROXY = [
  'get',
  'post',
  'put',
  'allDocs',
  'bulkDocs'
];

class PouchDbProxy {
  constructor(_delegate) {
    this._delegate = _delegate;
    _.each(FN_NAMES_TO_PROXY, fnName => {
      return this[fnName] = this.wrap(this._delegate[fnName].bind(this._delegate));
    }
    );
  }
}

class BluebirdPromisePouchDb extends PouchDbProxy {
  wrap(fn) { return (...args) => Promise.resolve(fn(...args)); }
}

class RetryingPouchDb extends PouchDbProxy {
  wrap(fn) { return function(...args) {
    const retryHelper = retries =>
      fn(...args)
      .catch(function(e) {
        if (retries > 0) {
          return retryHelper(retries - 1);
        } else {
          throw e;
        }
      })
    ;

    return retryHelper(1);
  }; }
}

const get = _.once(function() {
  let dbOptions;
  const config = require('./config');
  const auth   = _.pick(config.couchDb, 'username', 'password');
  if (_.size(auth) === 2) {
    dbOptions = { auth };
  } else {
    dbOptions = {};
  }

  return _.mapValues({
    recipeDb     : config.couchDb.url + config.couchDb.recipeDbName,
    configDb     : config.couchDb.url + config.couchDb.configDbName,
    ingredientDb : config.couchDb.url + config.couchDb.ingredientDbName
  }, url => new RetryingPouchDb(new BluebirdPromisePouchDb(new PouchDB(url, dbOptions))));
});

module.exports = { get };

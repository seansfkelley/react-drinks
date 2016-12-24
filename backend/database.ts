import { once, size, pick, mapValues } from 'lodash';
import * as log from 'loglevel';
import * as PouchDBConstructor from 'pouchdb';
import * as Promise from 'bluebird';

import config from './config';
import { Ingredient, Recipe } from '../shared/types';

const PROXY_BLUEBIRD_PROMISE: ProxyHandler<any> = {
  get: (target, name) => {
    if (typeof target[name] === 'function') {
      return (...args) => {
        const result = target[name](...args);
        if (result && typeof result.then === 'function') {
          return Promise.resolve(result);
        } else {
          return result;
        }
      };
    } else {
      return target[name];
    }
  }
};

const PROXY_RETRY: ProxyHandler<any> = {
  get: (target, name) => {
    if (typeof target[name] === 'function') {
      return (...args) => {
        const retryHelper = (retries: number) => {
          let result;
          try {
            result = target[name](...args);
          } catch (e) {
            if (retries > 0) {
              return retryHelper(retries - 1);
            } else {
              throw e;
            }
          }

          if (result && typeof result.then === 'function') {
            return result
              .then(
                success => success,
                error => {
                  if (retries > 0) {
                    return retryHelper(retries - 1);
                  } else {
                    throw error;
                  }
                }
              );
          } else {
            return result;
          }
        }

        return retryHelper(1);
      };
    } else {
      return target[name];
    }
  }
};

function createDatabases() {
  const auth = pick(config.couchDb, 'username', 'password') as {};
  const dbOptions = size(auth) === 2 ? { auth } : {};

  function makeDb<T>(dbName: string): PouchDB.Database<T> {
    return new Proxy<PouchDB.Database<T>>(
      new Proxy<PouchDB.Database<T>>(
        new PouchDBConstructor<T>(config.couchDb.url + dbName, dbOptions),
        PROXY_RETRY
      ),
      PROXY_BLUEBIRD_PROMISE)
  }

  return {
    ingredientDb: makeDb<Ingredient>(config.couchDb.ingredientDbName),
    recipeDb: makeDb<Recipe>(config.couchDb.recipeDbName),
    configDb: makeDb<any>(config.couchDb.configDbName)
  };
}

export const get = once(createDatabases);


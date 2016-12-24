import { once, size, pick, mapValues } from 'lodash';
import * as log from 'loglevel';
import * as PouchDBConstructor from 'pouchdb';
import * as Promise from 'bluebird';

import config from './config';
import { Ingredient, Recipe } from '../shared/types';
import { PROXY_RETRY, PROXY_BLUEBIRD_PROMISE } from './proxies';

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


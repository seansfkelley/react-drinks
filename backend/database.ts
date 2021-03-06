import { once, size, pick } from 'lodash';
import * as PouchDBConstructor from 'pouchdb';

import config from './config';
import { Ingredient, DbRecipe } from '../shared/types';
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
    recipeDb: makeDb<DbRecipe>(config.couchDb.recipeDbName),
    configDb: makeDb<any>(config.couchDb.configDbName)
  };
}

export const get = once(createDatabases);

import { assign, omit, keyBy, mapValues, keys, difference } from 'lodash';
import * as log from 'loglevel';

import { DbRecipe } from '../shared/types';
import { get as getDatabase } from './database';

const { recipeDb, configDb } = getDatabase();

export function getDefaultRecipeIds(): Promise<string[]> {
  return configDb.get('default-recipe-list')
    .then(({ defaultIds }) => defaultIds);
}

export function save(recipe: DbRecipe): Promise<string> {
  return recipeDb.post(recipe)
    .then(({ id }) => {
      log.info(`saved new recipe with ID ${ id }`);
      return id;
    });
}

export function load(recipeId: string): Promise<DbRecipe | undefined> {
  return recipeDb.get(recipeId)
    .then((recipe: DbRecipe) => {
      if (recipe) {
        return assign({ recipeId }, omit(recipe, '_id') as DbRecipe);
      } else {
        log.info(`failed to find recipe with ID '${ recipeId }'`);
        return undefined;
      }
    });
}

export function bulkLoad(recipeIds?: string[]): Promise<{ [recipeId: string]: DbRecipe }> {
  if (!recipeIds || recipeIds.length === 0) {
    return Promise.resolve({});
  } else {
    return recipeDb.allDocs({
      keys: recipeIds,
      include_docs: true
    })
      .then(({ rows }) => {
        const recipes = mapValues(
          keyBy(rows.map(r => r.doc).filter(d => !!d), '_id'),
          d => omit(d as {}, '_id', '_rev') as DbRecipe
        );

        const loadedIds = keys(recipes);
        const missingIds = difference(recipeIds, loadedIds);
        if (missingIds.length) {
          log.warn(`failed to bulk-load some recipes: ${missingIds.join(', ')}`);
        }

        return recipes;
      });
  }
};

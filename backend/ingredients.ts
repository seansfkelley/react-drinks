import { omit } from 'lodash';

import { Ingredient, IngredientGroupMeta } from '../shared/types';
import { get as getDatabase } from './database';

const { ingredientDb, configDb } = getDatabase();

export function getIngredients(): Promise<Ingredient[]> {
  return ingredientDb.allDocs({
    include_docs: true
  })
    .then(({ rows }) => {
      return rows.map(r => omit(r.doc as {}, '_id', '_rev') as Ingredient);
    });
}

export function getGroups(): Promise<IngredientGroupMeta[]> {
  return configDb.get('ingredient-groups')
    .then(({ orderedGroups }) => orderedGroups);
}

import { omit } from 'lodash';

import { Ingredient } from '../shared/types';
import { get as getDatabase } from './database';

const { ingredientDb } = getDatabase();

export function getIngredients(): Promise<Ingredient[]> {
  return ingredientDb.allDocs({
    include_docs: true
  })
    .then(({ rows }) => {
      return rows.map(r => omit(r.doc as {}, '_id', '_rev') as Ingredient);
    });
}

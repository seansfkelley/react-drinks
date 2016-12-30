import { uniq, sum } from 'lodash';
import { Recipe, DisplayIngredient } from '../../../shared/types';

export function computeRecipeSimilarity(recipe1: Recipe, recipe2: Recipe) {
  const allRelevantTags = uniq(([] as DisplayIngredient[])
    .concat(recipe1.ingredients)
    .concat(recipe2.ingredients)
    .map(i => i.tag)
    .filter(t => !!t)
  );
  function makeFeatureVector(r: Recipe) {
    // TODO: Doesn't do anything about similar/substitutable ingredients.
    return allRelevantTags.map(t => r.ingredients.some(i => i.tag === t) ? 1 : 0);
  }
  const vector1 = makeFeatureVector(recipe1);
  const vector2 = makeFeatureVector(recipe2);

  // cosine similarity
  return (
    allRelevantTags.reduce((dotProduct, _tag, i) => dotProduct + vector1[i] * vector2[i], 0)
    /
    (sum(vector1) * sum(vector2))
  );
}

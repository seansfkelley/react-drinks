import { clone, deburr } from 'lodash';
import { assert } from './tinyassert';
import { Ingredient, Recipe } from './types';

export function normalizeIngredient(ingredient: Partial<Ingredient>): Ingredient {
  assert(ingredient.display);

  // TODO: this `as any` forces me to lie to the type system.
  const normalized: Ingredient = clone(ingredient) as any;
  if (normalized.tag == null) {
    normalized.tag = normalized.display!.toLowerCase();
  }
  if (normalized.searchable == null) {
    normalized.searchable = [];
  }
  normalized.searchable.push(deburr(normalized.display).toLowerCase());
  normalized.searchable.push(normalized.tag);
  if (normalized.tangible == null) {
    normalized.tangible = true;
  }
  // TODO: Add display for generic to here.
  // if i.generic and not _.contains i.searchable, i.generic
  //   i.searchable.push i.generic
  return normalized;
};

export function normalizeRecipe(recipe: Partial<Recipe>): Recipe {
  assert(recipe.name);

  // TODO: this `as any` forces me to lie to the type system.
  const normalized: Recipe = clone(recipe) as any;
  normalized.canonicalName = deburr(normalized.name).toLowerCase();
  const nameWords = normalized.canonicalName.split(' ');
  if (['a', 'the'].indexOf(nameWords[0]) !== -1) {
    normalized.sortName = nameWords.slice(1).join(' ');
  } else {
    normalized.sortName = normalized.canonicalName;
  }
  if (normalized.base == null) {
    normalized.base = [];
  }
  return normalized;
};

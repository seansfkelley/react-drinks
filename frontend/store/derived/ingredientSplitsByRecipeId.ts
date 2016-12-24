import { assign, uniq, isPlainObject, omit } from 'lodash';
import * as log from 'loglevel';

import { Ingredient, Recipe, DisplayIngredient } from '../../../shared/types';
import { memoize } from './memoize';
import { assert } from '../../../shared/tinyassert';

export interface IngredientSplit {
  missing: DisplayIngredient[];
  available: DisplayIngredient[];
  substitute: { need: DisplayIngredient, have: string[] }[];
}

export function _countSubsetMissing(small: any[], large: any[]) {
  let missed = 0;
  for (let s of small) {
    if (!large.includes(s)) {
      missed++;
    }
  }
  return missed;
}

export function _includeAllGenerics({ ingredients, ingredientsByTag }: { ingredients: Ingredient[], ingredientsByTag: { [tag: string]: Ingredient } }) {
  const withGenerics: Ingredient[] = [];

  for (let current of ingredients) {
    withGenerics.push(current);
    while (current = ingredientsByTag[current.generic!]) {
      withGenerics.push(current);
    }
  }

  return uniq(withGenerics);
}

export function _toMostGenericTags({ ingredients, ingredientsByTag }: { ingredients: Ingredient[], ingredientsByTag: { [tag: string]: Ingredient } }) {
  return uniq(_includeAllGenerics({ ingredients, ingredientsByTag })
    .filter(i => !i.generic)
    .map(i => i.tag));
}

export function _computeSubstitutionMap({ ingredients, ingredientsByTag }: { ingredients: Ingredient[], ingredientsByTag: { [tag: string]: Ingredient } }) {
  const ingredientsByTagWithGenerics: { [tag: string]: string[] } = {};
  for (let i of ingredients) {
    let generic = i;
    (ingredientsByTagWithGenerics[generic.tag] != null ? ingredientsByTagWithGenerics[generic.tag] : ingredientsByTagWithGenerics[generic.tag!] = []).push(i.tag);
    while (generic = ingredientsByTag[generic.generic!]) {
      (ingredientsByTagWithGenerics[generic.tag] != null ? ingredientsByTagWithGenerics[generic.tag] : ingredientsByTagWithGenerics[generic.tag!] = []).push(i.tag);
    }
  }
  return ingredientsByTagWithGenerics;
};

export function _generateSearchResult({ recipe, substitutionMap, ingredientsByTag }: { recipe: Recipe, substitutionMap: { [tag: string]: string[] }, ingredientsByTag: { [tag: string]: Ingredient } }) {
  const splits: IngredientSplit = {
    missing: [],
    available: [],
    substitute: []
  };

  for (let ingredient of recipe.ingredients) {
    if (ingredient.tag == null) {
      // Things like 'water' are untagged.
      splits.available.push(ingredient);
    } else if (substitutionMap[ingredient.tag] != null) {
      splits.available.push(ingredient);
    } else {
      let currentTag: string | undefined = ingredient.tag;
      while (currentTag != null) {
        if (substitutionMap[currentTag] != null) {
          splits.substitute.push({
            need: ingredient,
            have: substitutionMap[currentTag].map(t => ingredientsByTag[t].display)
          });
          break;
        }
        const currentIngredient = ingredientsByTag[currentTag];
        if (currentIngredient == null) {
          log.warn(`recipe '${recipe.name}' calls for or has a generic that calls for unknown tag '${currentTag}'`);
        }
        if (currentIngredient && ingredientsByTag[currentIngredient.generic!]) {
          currentTag = ingredientsByTag[currentIngredient.generic!].tag;
        } else {
          currentTag = undefined;
        }
      }
      if (currentTag == null) {
        splits.missing.push(ingredient);
      }
    }
  }

  return assign({ recipeId: recipe.recipeId }, splits);
};

export function ingredientSplitsByRecipeId({ recipes, ingredientsByTag, ingredientTags }: { recipes: Recipe[], ingredientsByTag: { [tag: string]: Ingredient }, ingredientTags: string[] | { [tag: string]: any } }) {
  // Fucking hell I just want Set objects.
  const tags: string[] = isPlainObject(ingredientTags) ? Object.keys(ingredientTags) : (ingredientTags as string[]);

  const exactlyAvailableIngredientsRaw = tags.map(t => ingredientsByTag[t]);
  const exactlyAvailableIngredients = exactlyAvailableIngredientsRaw.filter(i => !!i);
  if (exactlyAvailableIngredientsRaw.length !== exactlyAvailableIngredients.length) {
    const extraneous = exactlyAvailableIngredientsRaw
      .map((value, i) => value == null ? tags[i] : null)
      .filter(t => !!t);
    log.warn(`some tags that were searched are extraneous and will be ignored: ${JSON.stringify(extraneous)}`);
  }

  const substitutionMap = _computeSubstitutionMap({
    ingredients: exactlyAvailableIngredients,
    ingredientsByTag
  });
  const allAvailableTagsWithGenerics = Object.keys(substitutionMap);

  return recipes
    .map(r => {
      const indexableIngredients = r.ingredients
        .filter(i => !!i.tag)
        .map(i => ingredientsByTag[i.tag!]);
      const presentIndexableIngredients = indexableIngredients.filter(i => !!i);
      const unknownIngredientAdjustment = indexableIngredients.length - presentIndexableIngredients.length;
      const mostGenericRecipeTags = _toMostGenericTags({
        ingredients: presentIndexableIngredients,
        ingredientsByTag
      });
      const missingCount = _countSubsetMissing(mostGenericRecipeTags, allAvailableTagsWithGenerics) + unknownIngredientAdjustment;
      return _generateSearchResult({
        recipe: r,
        substitutionMap,
        ingredientsByTag
      });
    })
    .reduce((obj, result) => {
      obj[result.recipeId] = omit(result, 'recipeId') as IngredientSplit;
      return obj;
    }, {} as { [recipeId: string]: IngredientSplit });
};

export const memoized = memoize(ingredientSplitsByRecipeId);

import { memoize, once, keyBy } from 'lodash';
import { readFileSync } from 'fs';
import { safeLoad } from 'js-yaml';
import * as log from 'loglevel';

import { assert } from '../shared/tinyassert';
import { Ingredient, DbRecipe } from '../shared/types';
import { normalizeIngredient, normalizeRecipe } from '../shared/normalization';
import { validateOrThrow, REQUIRED_STRING, OPTIONAL_STRING } from './revalidator-utils';

type ActuallyUsefulRevalidatorType = Revalidator.ISchema<any> & Revalidator.JSONSchema<any> ;

const INGREDIENT_SCHEMA: ActuallyUsefulRevalidatorType = {
  type: 'object',
  properties: {
    // The display name of the ingredient.
    display: REQUIRED_STRING,
    // The uniquely identifying tag for this ingredient. Defaults to the lowercase display name.
    tag: OPTIONAL_STRING,
    // The tag for the generic (substitutable) ingredient for this ingredient. If the target doesn't
    // exist, a new invisible ingredient is added.
    generic: OPTIONAL_STRING,
    // An array of searchable terms for the ingredient. Includes the display name of itself and its
    // generic (if it exists) by default.
    searchable: {
      type: 'array',
      required: false,
      items: {
        type: 'string'
      }
    }
  }
};

const RECIPE_SCHEMA: ActuallyUsefulRevalidatorType  = {
  type: 'object',
  properties: {
    // The display name of the recipe.
    name: REQUIRED_STRING,
    // The measured ingredients for how to mix this recipe.
    ingredients: {
      type: 'array',
      required: true,
      items: {
        properties: {
          tag: OPTIONAL_STRING,
          displayAmount: {
            type: 'string',
            required: false,
            pattern: /^[-. \/\d]+$/
          },
          displayUnit: OPTIONAL_STRING,
          displayIngredient: REQUIRED_STRING
        }
      }
    },
    // A string of one or more lines explaining how to make the drink.
    instructions: REQUIRED_STRING,
    // A string of one or more lines with possibly interesting suggestions or historical notes.
    notes: OPTIONAL_STRING,
    // The display name for the source of this recipe.
    source: OPTIONAL_STRING,
    // The full URL to the source page for this recipe.
    url: OPTIONAL_STRING
  }
};

export const loadRecipeFile = memoize((filename: string) => {
  log.debug(`loading recipes from ${filename}`);
  const recipes: Partial<DbRecipe>[] = safeLoad(readFileSync(`${__dirname}/data/${filename}.yaml`).toString());
  log.debug(`loaded ${recipes.length} recipe(s) from ${filename}`);

  validateOrThrow(recipes, {
    type: 'array',
    items: RECIPE_SCHEMA
  });

  return recipes.map(normalizeRecipe);
});

export const loadIngredients = once(() => {
  log.debug("loading ingredients");
  const ingredients: Partial<Ingredient>[] = safeLoad(readFileSync(`${__dirname}/data/ingredients.yaml`).toString());
  log.debug(`loaded ${ingredients.length} ingredients`);

  validateOrThrow(ingredients, {
    type: 'array',
    items: INGREDIENT_SCHEMA
  });

  const normalizedIngredients = ingredients.map(normalizeIngredient);
  const extantIngredientKeys = keyBy(normalizedIngredients, i => i.tag);

  normalizedIngredients.forEach(i => {
    if (i.generic) {
      assert(extantIngredientKeys[i.generic], `ingredient with tag '${i.tag}' specifies unknown generic '${i.generic}'`);
    }
  });

  return normalizedIngredients;
});

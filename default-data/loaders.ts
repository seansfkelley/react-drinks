import { isString, isArray, memoize, once } from 'lodash';
import { readFileSync } from 'fs';
import { safeLoad } from 'js-yaml';
import * as log from 'loglevel';

import { Ingredient, IngredientGroupMeta, DbRecipe } from '../shared/types';
import { normalizeIngredient, normalizeRecipe } from '../shared/normalization';
import { UNASSIGNED_BASE_LIQUOR, BASE_LIQUORS } from '../shared/definitions';
import { validateOrThrow, REQUIRED_STRING, OPTIONAL_STRING } from './revalidator-utils';

const xor = (a: boolean, b: boolean) => (a || b) && !(a && b);

const ALL_BASE_LIQUORS = [UNASSIGNED_BASE_LIQUOR].concat(BASE_LIQUORS);

type ActuallyUsefulRevalidatorType = Revalidator.ISchema<any> & Revalidator.JSONSchema<any> ;

const INGREDIENT_SCHEMA: ActuallyUsefulRevalidatorType = {
  type: 'object',
  properties: {
    // The display name of the ingredient.
    display: REQUIRED_STRING,
    // The category this ingredient is in (e.g., spirit, mixer, syrup...)
    group: {
      type: 'string',
      conform: (v, object) => {
        return xor(v != null, !(object.tangible != null ? object.tangible : true));
      }
    },
    // Intangible ingredients are useful to index on or specify, but are not specific enough to
    // warrant being something you can have in your cabinet. The canonical example is Chartreuse
    // (either variety), but it's also useful for e.g whiskey as a generic.
    tangible: {
      type: 'boolean',
      conform: (v, object) => {
        return xor(!(v != null ? v : true), object.group != null);
      }
    },
    // The uniquely identifying tag for this ingredient. Defaults to the lowercase display name.
    tag: OPTIONAL_STRING,
    // The tag for the generic (substitutable) ingredient for this ingredient. If the target doesn't
    // exist, a new invisible ingredient is added.
    generic: OPTIONAL_STRING,
    // An approximate rating for how difficult this ingredient is to buy.
    difficulty: {
      type: 'string',
      enum: ['easy', 'medium', 'hard']
    },
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
    url: OPTIONAL_STRING,
    // One of a few very broad ingredient categories that best describes the genre of this drink.
    base: {
      type: ['array', 'string'],
      required: true,
      conform: (strOrArray: string | string[]) => {
        if (isString(strOrArray)) {
          return ALL_BASE_LIQUORS.indexOf(strOrArray) !== -1;
        } else if (isArray(strOrArray)) {
          return strOrArray.every(base => ALL_BASE_LIQUORS.indexOf(base) !== -1);
        } else {
          return false;
        }
      }
    }
  }
};

const INGREDIENT_GROUP_SCHEMA: ActuallyUsefulRevalidatorType = {
  type: 'object',
  properties: {
    type: REQUIRED_STRING,
    display: REQUIRED_STRING
  }
};

export const loadRecipeFile = memoize((filename: string) => {
  log.debug(`loading recipes from ${filename}`);
  const recipes: Partial<DbRecipe>[] = safeLoad(readFileSync(`${__dirname}/data/${filename}.yaml`).toString());
  log.debug(`loaded ${recipes.length} recipe(s) from ${filename}`);

  const unassignedBases = recipes.filter(r => r.base === UNASSIGNED_BASE_LIQUOR);
  if (unassignedBases.length) {
    log.warn(`${unassignedBases.length} recipe(s) in ${filename} have an unassigned base liquor: ${unassignedBases.map(r => r.name).join(', ') }`);
  }

  validateOrThrow(recipes, {
    type: 'array',
    items: RECIPE_SCHEMA
  });

  return recipes.map(normalizeRecipe);
});

export const loadIngredientGroups = once(() => {
  log.debug("loading ingredient grouping");
  const groups: IngredientGroupMeta[] = safeLoad(readFileSync(`${__dirname}/data/groups.yaml`).toString());
  log.debug(`loaded ${groups.length} groups`);

  validateOrThrow(groups, {
    type: 'array',
    items: INGREDIENT_GROUP_SCHEMA
  });

  return groups;
});

export const loadIngredients = once(() => {
  log.debug("loading ingredients");
  const ingredients: Partial<Ingredient>[] = safeLoad(readFileSync(`${__dirname}/data/ingredients.yaml`).toString());
  log.debug(`loaded ${ingredients.length} ingredients`);

  validateOrThrow(ingredients, {
    type: 'array',
    items: INGREDIENT_SCHEMA
  });

  return ingredients.map(normalizeIngredient);
});

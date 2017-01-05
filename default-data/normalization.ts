import { deburr, assign } from 'lodash';
import { assert } from '../shared/tinyassert';
import { Ingredient, DbRecipe } from '../shared/types';

export function normalizeIngredient(ingredient: Partial<Ingredient>): Ingredient {
  assert(ingredient.display);
  assert(ingredient.display!.trim());

  const display = ingredient.display!.trim();
  const tag = ingredient.tag || display.toLowerCase();
  const ingredientAdditions = {
    tag,
    display,
    searchable: (ingredient.searchable || []).concat([ deburr(display).toLowerCase() ])
  };

  return assign(ingredientAdditions, ingredient);
};

export function normalizeRecipe(recipe: Partial<DbRecipe>): DbRecipe {
  assert(recipe.name);
  assert(recipe.name!.trim());

  const name = recipe.name!.trim();
  const canonicalName = deburr(name).toLowerCase();
  const nameWords = canonicalName.split(' ')
  const recipeAdditions = {
    name,
    canonicalName,
    sortName: nameWords.slice([ 'a', 'the' ].includes(nameWords[0]) ? 1 : 0).join(' '),
    // Make the type system happy by reiterating these...
    ingredients: recipe.ingredients!,
    instructions: recipe.instructions!
  };

  return assign(recipeAdditions, recipe);
};

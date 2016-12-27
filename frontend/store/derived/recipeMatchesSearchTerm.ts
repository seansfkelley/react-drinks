import { Recipe, Ingredient } from '../../../shared/types';

const WHITESPACE_REGEX = /\s+/g;

// SO INEFFICIENT.
export function recipeMatchesSearchTerm({ recipe, searchTerm, ingredientsByTag }: { recipe: Recipe, searchTerm?: string, ingredientsByTag: { [tag: string]: Ingredient } }) {
  if (searchTerm == null) {
    searchTerm = '';
  }

  if (searchTerm.trim().length === 0) {
    return false;
  }

  const terms = searchTerm.trim().split(WHITESPACE_REGEX).filter(t => !!t);
  const searchable = recipe.ingredients
    .map(i => i.tag)
    .map(tag => ingredientsByTag[tag!] && ingredientsByTag[tag!].searchable)
    .filter(terms => !!terms)
    .reduce((acc, next) => acc.concat(next), [])
    .concat(recipe.canonicalName.split(WHITESPACE_REGEX));

  return terms.every(t => searchable.some(s => s.indexOf(t) !== -1));
};

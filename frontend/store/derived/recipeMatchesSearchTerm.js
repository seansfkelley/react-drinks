const _ = require('lodash');

const assert = require('../../../shared/tinyassert');

const memoize = require('./memoize');

const WHITESPACE_REGEX = /\s+/g;

// SO INEFFICIENT.
const recipeMatchesSearchTerm = function({ recipe, searchTerm, ingredientsByTag }) {
  if (searchTerm == null) { searchTerm = ''; }

  assert(recipe);
  assert(ingredientsByTag);

  if (!searchTerm.trim()) {
    return false;
  }

  const terms = _.compact(searchTerm.trim().split(WHITESPACE_REGEX));

  const searchable = _.chain(recipe.ingredients)
    .pluck('tag')
    .map(t => __guard__(ingredientsByTag[t], x => x.searchable))
    .compact()
    .flatten()
    .concat(recipe.canonicalName.split(WHITESPACE_REGEX))
    .value();

  return _.all(terms, t => _.any(searchable, s => s.indexOf(t) !== -1));
};

module.exports = _.extend(recipeMatchesSearchTerm, {
  memoized : memoize(recipeMatchesSearchTerm)
});

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
const _ = require('lodash');

const assert = require('../../../shared/tinyassert');

const memoize = require('./memoize');

const filteredGroupedIngredients = function({ groupedIngredients, searchTerm }) {
  let left;
  if (searchTerm == null) { searchTerm = ''; }

  assert(groupedIngredients);

  if (((left = searchTerm.trim()) != null ? left : '') === '') {
    return groupedIngredients;
  } else {
    searchTerm = searchTerm.toLowerCase();

    const filterBySearchTerm = function(i) {
      for (let term of i.searchable) {
        if (term.indexOf(searchTerm) !== -1) {
          return true;
        }
      }
      return false;
    };

    return _.chain(groupedIngredients)
      .map(function({ name, ingredients }) {
        ingredients = _.filter(ingredients, filterBySearchTerm);
        return { name, ingredients };})
      .filter(({ ingredients }) => ingredients.length > 0)
      .value();
  }
};

module.exports = _.extend(filteredGroupedIngredients, {
  memoized : memoize(filteredGroupedIngredients)
});

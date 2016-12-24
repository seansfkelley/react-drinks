const _ = require('lodash');
const log = require('loglevel');

const assert = require('../../../shared/tinyassert');
const definitions = require('../../../shared/definitions');

const memoize = require('./memoize');
const ingredientSplitsByRecipeId = require('./ingredientSplitsByRecipeId').memoized;
const recipeMatchesSearchTerm = require('./recipeMatchesSearchTerm').memoized;

// hee hee
const nofilter = () => true;

const _baseLiquorFilter = function (baseLiquorFilter) {
  if (baseLiquorFilter !== definitions.ANY_BASE_LIQUOR) {
    return function (recipe) {
      if (_.isString(recipe.base)) {
        return recipe.base === baseLiquorFilter;
      } else if (_.isArray(recipe.base)) {
        return recipe.base.includes(baseLiquorFilter);
      } else {
        log.warn(`recipe '${ recipe.name }' has a non-string, non-array base: ${ recipe.base }`);
        return false;
      }
    };
  } else {
    return nofilter;
  }
};

const _searchTermFilter = function (searchTerm, ingredientsByTag) {
  searchTerm = searchTerm.trim();
  if (searchTerm) {
    return recipe => recipeMatchesSearchTerm({
      recipe,
      searchTerm,
      ingredientsByTag
    });
  } else {
    return nofilter;
  }
};

const _recipeListFilter = (listType, ingredientSplits, favoritedRecipeIds) => (() => {
  switch (listType) {
    case 'all':
      return nofilter;
    case 'mixable':
      return recipe => ingredientSplits[recipe.recipeId].missing.length === 0;
    case 'favorites':
      return recipe => _.contains(favoritedRecipeIds, recipe.recipeId);
    case 'custom':
      return recipe => !!recipe.isCustom;
  }
})();

const _sortAndGroupAlphabetical = recipes => _.chain(recipes).sortBy('sortName').groupBy(function (r) {
  const key = r.sortName[0].toLowerCase();
  if (/\d/.test(key)) {
    return '#';
  } else {
    return key;
  }
}).map((recipes, key) => ({ recipes, key })).sortBy('key').value();

const filteredGroupedRecipes = function ({
  ingredientsByTag,
  recipes,
  baseLiquorFilter,
  searchTerm,
  ingredientTags,
  favoritedRecipeIds,
  selectedRecipeList
}) {
  if (searchTerm == null) {
    searchTerm = '';
  }
  if (baseLiquorFilter == null) {
    baseLiquorFilter = definitions.ANY_BASE_LIQUOR;
  }

  assert(ingredientsByTag);
  assert(recipes);
  assert(ingredientTags);
  assert(favoritedRecipeIds);
  assert(selectedRecipeList);

  const ingredientSplits = ingredientSplitsByRecipeId({ ingredientsByTag, recipes, ingredientTags });

  const filteredRecipes = _.chain(recipes).filter(_baseLiquorFilter(baseLiquorFilter)).filter(_recipeListFilter(selectedRecipeList, ingredientSplits, favoritedRecipeIds)).filter(_searchTermFilter(searchTerm, ingredientsByTag)).value();

  return _sortAndGroupAlphabetical(filteredRecipes);
};

module.exports = _.extend(filteredGroupedRecipes, {
  memoized: memoize(filteredGroupedRecipes),
  __test: {
    _baseLiquorFilter,
    _searchTermFilter,
    _recipeListFilter,
    _sortAndGroupAlphabetical
  }
});
import {} from 'lodash';
import * as log from 'loglevel';

const memoize = require('./memoize');
const assert = require('../../../shared/tinyassert');

const _countSubsetMissing = function (small, large) {
  let missed = 0;
  for (let s of small) {
    if (!large.includes(s)) {
      missed++;
    }
  }
  return missed;
};

const _includeAllGenerics = function ({ ingredients, ingredientsByTag }) {
  const withGenerics = [];

  for (let current of ingredients) {
    withGenerics.push(current);
    while (current = ingredientsByTag[current.generic]) {
      withGenerics.push(current);
    }
  }

  return _.uniq(withGenerics);
};

const _toMostGenericTags = ({ ingredients, ingredientsByTag }) => _.chain(_includeAllGenerics({ ingredients, ingredientsByTag })).reject('generic').pluck('tag').uniq().value();

const _computeSubstitutionMap = function ({ ingredients, ingredientsByTag }) {
  const ingredientsByTagWithGenerics = {};
  for (let i of ingredients) {
    let generic = i;
    (ingredientsByTagWithGenerics[generic.tag] != null ? ingredientsByTagWithGenerics[generic.tag] : ingredientsByTagWithGenerics[generic.tag] = []).push(i.tag);
    while (generic = ingredientsByTag[generic.generic]) {
      (ingredientsByTagWithGenerics[generic.tag] != null ? ingredientsByTagWithGenerics[generic.tag] : ingredientsByTagWithGenerics[generic.tag] = []).push(i.tag);
    }
  }
  return ingredientsByTagWithGenerics;
};

const _generateSearchResult = function ({ recipe, substitutionMap, ingredientsByTag }) {
  const missing = [];
  const available = [];
  const substitute = [];

  for (let ingredient of recipe.ingredients) {
    if (ingredient.tag == null) {
      // Things like 'water' are untagged.
      available.push(ingredient);
    } else if (substitutionMap[ingredient.tag] != null) {
      available.push(ingredient);
    } else {
      let currentTag = ingredient.tag;
      while (currentTag != null) {
        if (substitutionMap[currentTag] != null) {
          substitute.push({
            need: ingredient,
            have: _.map(substitutionMap[currentTag], t => ingredientsByTag[t].display)
          });
          break;
        }
        const currentIngredient = ingredientsByTag[currentTag];
        if (currentIngredient == null) {
          log.warn(`recipe '${ recipe.name }' calls for or has a generic that calls for unknown tag '${ currentTag }'`);
        }
        currentTag = __guard__(ingredientsByTag[__guard__(currentIngredient, x1 => x1.generic)], x => x.tag);
      }
      if (currentTag == null) {
        missing.push(ingredient);
      }
    }
  }

  return { recipeId: recipe.recipeId, missing, available, substitute };
};

const ingredientSplitsByRecipeId = function ({ recipes, ingredientsByTag, ingredientTags }) {
  assert(recipes);
  assert(ingredientsByTag);
  assert(ingredientTags);

  // Fucking hell I just want Set objects.
  if (_.isPlainObject(ingredientTags)) {
    ingredientTags = _.keys(ingredientTags);
  }

  const exactlyAvailableIngredientsRaw = _.map(ingredientTags, tag => ingredientsByTag[tag]);
  const exactlyAvailableIngredients = _.compact(exactlyAvailableIngredientsRaw);
  if (exactlyAvailableIngredientsRaw.length !== exactlyAvailableIngredients.length) {
    const extraneous = _.chain(exactlyAvailableIngredientsRaw).map((value, i) => {
      if (value == null) {
        return ingredientTags[i];
      }
    }).compact().value();
    log.warn(`some tags that were searched are extraneous and will be ignored: ${ JSON.stringify(extraneous) }`);
  }

  const substitutionMap = _computeSubstitutionMap({
    ingredients: exactlyAvailableIngredients,
    ingredientsByTag
  });
  const allAvailableTagsWithGenerics = _.keys(substitutionMap);

  return _.chain(recipes).map(r => {
    const indexableIngredients = _.chain(r.ingredients).filter('tag').map(i => ingredientsByTag[i.tag]).value();
    const unknownIngredientAdjustment = indexableIngredients.length - _.compact(indexableIngredients).length;
    const mostGenericRecipeTags = _toMostGenericTags({
      ingredients: _.compact(indexableIngredients),
      ingredientsByTag
    });
    const missingCount = _countSubsetMissing(mostGenericRecipeTags, allAvailableTagsWithGenerics) + unknownIngredientAdjustment;
    return _generateSearchResult({
      recipe: r,
      substitutionMap,
      ingredientsByTag
    });
  }).compact().reduce(function (obj, result) {
    obj[result.recipeId] = _.omit(result, 'recipeId');return obj;
  }, {}).value();
};

module.exports = _.extend(ingredientSplitsByRecipeId, {
  __test: {
    _countSubsetMissing,
    _includeAllGenerics,
    _toMostGenericTags,
    _computeSubstitutionMap,
    _generateSearchResult
  },
  memoized: memoize(ingredientSplitsByRecipeId)
});

function __guard__(value, transform) {
  return typeof value !== 'undefined' && value !== null ? transform(value) : undefined;
}

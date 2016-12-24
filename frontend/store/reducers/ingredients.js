const _ = require('lodash');
const log = require('loglevel');

const normalization = require('../../../shared/normalization');
const { ANY_BASE_LIQUOR } = require('../../../shared/definitions');

const _displaySort = i => i.display.toLowerCase();

const _computeIngredientsByTag = function (ingredients, intangibleIngredients) {
  const ingredientsByTag = _.chain(ingredients).filter(i => i.tag != null).reduce(function (map, i) {
    map[i.tag] = i;return map;
  }, {}).value();

  for (var i of intangibleIngredients) {
    ingredientsByTag[i.tag] = i;
    ingredients.push(i);
  }

  for (i of ingredients) {
    if (i.generic != null && ingredientsByTag[i.generic] == null) {
      log.trace(`ingredient ${ i.tag } refers to unknown generic ${ i.generic }; inferring generic`);
      ingredientsByTag[i.generic] = normalization.normalizeIngredient({
        tag: i.generic,
        display: `[inferred] ${ i.generic }`
      });
    }
  }

  return ingredientsByTag;
};

const _computeGroupedIngredients = (ingredients, groups) => _.chain(ingredients).filter('tangible').sortBy(_displaySort).groupBy('group').map((ingredients, groupTag) => ({
  name: _.findWhere(groups, { type: groupTag }).display,
  ingredients
})).sortBy(({ name }) => _.findIndex(groups, { display: name })).value();

module.exports = require('./makeReducer')(_.extend({
  alphabeticalIngredients: [],
  allAlphabeticalIngredients: [],
  groupedIngredients: [],
  ingredientsByTag: {}
}, require('../persistence').load().ingredients), {
  ['set-ingredients'](state, { ingredients, groups }) {
    // We don't use state, this is a set-once kind of deal.
    return {
      allAlphabeticalIngredients: _.sortBy(ingredients, _displaySort),
      alphabeticalIngredients: _.sortBy(_.filter(ingredients, 'tangible'), _displaySort),
      ingredientsByTag: _computeIngredientsByTag(ingredients, _.reject(ingredients, 'tangible')),
      groupedIngredients: _computeGroupedIngredients(ingredients, groups)
    };
  }
});
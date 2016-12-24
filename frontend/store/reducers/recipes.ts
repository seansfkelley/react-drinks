import {} from 'lodash';

const _recomputeDerivedLists = function (state) {
  const alphabeticalRecipeIds = _.chain(state.recipesById).keys().sortBy(recipeId => state.recipesById[recipeId].sortName).value();

  return _.defaults({
    alphabeticalRecipeIds,
    alphabeticalRecipes: _.map(alphabeticalRecipeIds, recipeId => state.recipesById[recipeId])
  }, state);
};

module.exports = require('./makeReducer')(_.extend({
  // TODO: Remove this once bigger refactors are done.
  alphabeticalRecipes: [],
  alphabeticalRecipeIds: [],
  recipesById: {},
  customRecipeIds: []
}, require('../persistence').load().recipes), {
  ['recipes-loaded'](state, { recipesById }) {
    return _recomputeDerivedLists(_.defaults({ recipesById }, state));
  },

  ['saved-recipe'](state, { recipe }) {
    return _recomputeDerivedLists(_.defaults({
      customRecipeIds: state.customRecipeIds.concat([recipe.recipeId]),
      recipesById: _.defaults({
        [recipe.recipeId]: recipe
      }, state.recipesById)
    }, state));
  },

  ['delete-recipe'](state, { recipeId }) {
    return _recomputeDerivedLists(_.defaults({
      customRecipeIds: _.without(state.customRecipeIds, recipeId),
      recipesById: _.omit(state.recipesById, recipeId)
    }, state));
  }
});

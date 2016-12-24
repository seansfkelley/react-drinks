const _ = require('lodash');

const { parseIngredientFromText } = require('../../utils');

const EditableRecipePageType = require('../../EditableRecipePageType');

const _createEmptyStore = () => ({
  originalRecipeId: null,
  currentPage: EditableRecipePageType.NAME,
  name: '',
  ingredients: [],
  instructions: '',
  notes: '',
  base: [],
  saving: false
});

module.exports = require('./makeReducer')(_.extend(_createEmptyStore(), require('../persistence').load().editableRecipe), {
  ['seed-recipe-editor'](state, { recipe }) {
    return _.defaults({
      originalRecipeId: recipe.recipeId,
      ingredients: _.map(recipe.ingredients, i => ({
        tag: i.tag,
        isEditing: false,
        display: _.pick(i, 'displayAmount', 'displayUnit', 'displayIngredient')
      }))
    }, _.pick(recipe, 'name', 'instructions', 'notes', 'base'));
  },

  ['set-editable-recipe-page'](state, { page }) {
    return _.defaults({ currentPage: page }, state);
  },

  ['set-name'](state, { name }) {
    return _.defaults({ name }, state);
  },

  ['delete-ingredient'](state, { index }) {
    const ingredients = _.clone(state.ingredients);
    // Ugh side effects.
    ingredients.splice(index, 1);
    return _.defaults({ ingredients }, state);
  },

  ['add-ingredient'](state) {
    return _.defaults({
      ingredients: state.ingredients.concat([{ isEditing: true }])
    }, state);
  },

  ['commit-ingredient'](state, { index, rawText, tag }) {
    const ingredients = _.clone(state.ingredients);
    ingredients[index] = {
      tag,
      isEditing: false,
      display: parseIngredientFromText(rawText, tag)
    };
    return _.defaults({ ingredients }, state);
  },

  ['set-instructions'](state, { instructions }) {
    return _.defaults({ instructions }, state);
  },

  ['set-notes'](state, { notes }) {
    return _.defaults({ notes }, state);
  },

  ['toggle-base-liquor-tag'](state, { tag }) {
    let base;
    if (state.base.includes(tag)) {
      base = _.without(state.base, tag);
    } else {
      base = state.base.concat([tag]);
    }
    return _.defaults({ base }, state);
  },

  ['saving-recipe'](state) {
    return _.defaults({ saving: true }, state);
  },

  ['saved-recipe'](state) {
    return _createEmptyStore();
  },

  ['clear-editable-recipe'](state) {
    return _createEmptyStore();
  }
});
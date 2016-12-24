import { assign, defaults, pick, clone, without } from 'lodash';

import makeReducer from './makeReducer';
import { load } from '../persistence';
import { parseIngredientFromText } from '../../utils';
import { Recipe, DisplayIngredient } from '../../../shared/types';
import { EditableRecipePageType } from '../../types';

export interface EditableRecipeState {
  originalRecipeId?: string;
  currentPage: EditableRecipePageType;
  name: string;
  ingredients: {
    tag?: string;
    isEditing: boolean;
    display?: DisplayIngredient;
  }[];
  instructions: string;
  notes: string;
  base: string[];
  saving: boolean;
}

const _createEmptyStore = (): EditableRecipeState => ({
  originalRecipeId: undefined,
  currentPage: EditableRecipePageType.NAME,
  name: '',
  ingredients: [],
  instructions: '',
  notes: '',
  base: [],
  saving: false
});

export const reducer = makeReducer<EditableRecipeState>(assign(_createEmptyStore(), load().editableRecipe), {
  'seed-recipe-editor': (_state, { recipe }: { recipe: Recipe }) => {
    return defaults({
      originalRecipeId: recipe.recipeId,
      ingredients: recipe.ingredients.map(i => ({
        tag: i.tag,
        isEditing: false,
        display: pick(i, 'displayAmount', 'displayUnit', 'displayIngredient')
      }))
    }, pick(recipe, 'name', 'instructions', 'notes', 'base')) as EditableRecipeState;
  },

  'set-editable-recipe-page': (state, { page }) => {
    return defaults({ currentPage: page }, state);
  },

  'set-name': (state, { name }) => {
    return defaults({ name }, state);
  },

  'delete-ingredient': (state, { index }) => {
    const ingredients = clone(state.ingredients);
    // Ugh side effects.
    ingredients.splice(index, 1);
    return defaults({ ingredients }, state);
  },

  'add-ingredient': (state) => {
    return defaults({
      ingredients: state.ingredients.concat([{ isEditing: true }])
    }, state);
  },

  'commit-ingredient': (state, { index, rawText, tag }) => {
    const ingredients = clone(state.ingredients);
    ingredients[index] = {
      tag,
      isEditing: false,
      display: parseIngredientFromText(rawText)
    };
    return defaults({ ingredients }, state);
  },

  'set-instructions': (state, { instructions }) => {
    return defaults({ instructions }, state);
  },

  'set-notes': (state, { notes }) => {
    return defaults({ notes }, state);
  },

  'toggle-base-liquor-tag': (state, { tag }) => {
    let base;
    if (state.base.includes(tag)) {
      base = without(state.base, tag);
    } else {
      base = state.base.concat([tag]);
    }
    return defaults({ base }, state);
  },

  'saving-recipe': (state) => {
    return defaults({ saving: true }, state);
  },

  'saved-recipe': (_state) => {
    return _createEmptyStore();
  },

  'clear-editable-recipe': (_state) => {
    return _createEmptyStore();
  }
});

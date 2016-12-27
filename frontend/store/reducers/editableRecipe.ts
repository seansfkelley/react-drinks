import { assign, defaults, pick, clone, without } from 'lodash';

import makeReducer from './makeReducer';
import { load } from '../persistence';
import { parseIngredientFromText } from '../../utils';
import { Recipe, DisplayIngredient } from '../../../shared/types';
import { EditableRecipePageType } from '../../types';
import { Action } from '../ActionType';

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
  'seed-recipe-editor': (_state, action: Action<Recipe>) => {
    const recipe = action.payload!;
    return defaults({
      originalRecipeId: recipe.recipeId,
      ingredients: recipe.ingredients.map(i => ({
        tag: i.tag,
        isEditing: false,
        display: pick(i, 'displayAmount', 'displayUnit', 'displayIngredient')
      }))
    }, pick(recipe, 'name', 'instructions', 'notes', 'base')) as EditableRecipeState;
  },

  'set-editable-recipe-page': (state, action: Action<any>) => {
    return defaults({ currentPage: action.payload }, state);
  },

  'set-name': (state, action: Action<any>) => {
    return defaults({ name: action.payload }, state);
  },

  'delete-ingredient': (state, action: Action<any>) => {
    const ingredients = clone(state.ingredients);
    // Ugh side effects.
    ingredients.splice(action.payload, 1);
    return defaults({ ingredients }, state);
  },

  'add-ingredient': (state) => {
    return defaults({
      ingredients: state.ingredients.concat([{ isEditing: true }])
    }, state);
  },

  'commit-ingredient': (state, action: Action<any>) => {
    const { index, tag } = action.payload;
    const ingredients = clone(state.ingredients);
    ingredients[index] = {
      tag,
      isEditing: false,
      display: parseIngredientFromText(action.payload)
    };
    return defaults({ ingredients }, state);
  },

  'set-instructions': (state, action: Action<any>) => {
    return defaults({ instructions: action.payload }, state);
  },

  'set-notes': (state, action: Action<any>) => {
    return defaults({ notes: action.payload }, state);
  },

  'toggle-base-liquor-tag': (state, action: Action<any>) => {
    const tag = action.payload;
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

  'saved-recipe': () => {
    return _createEmptyStore();
  },

  'clear-editable-recipe': () => {
    return _createEmptyStore();
  }
});

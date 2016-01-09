_ = require 'lodash'

EditorWorkflow = require '../../recipe-editor/EditorWorkflow'

{ parseIngredientFromText } = require '../../utils'

EditableRecipePageType = require '../../EditableRecipePageType'

_createEmptyStore = -> {
  currentWorkflow  : null
  currentStep      : null
  editingRecipeId  : null
  isSaving         : false

  # guided/editing/prose
  name             : ''
  ingredients      : []
  instructions     : ''
  notes            : ''
  base             : []

  # prose
  providedProse    : null

  # id
  providedRecipeId : null
}

module.exports = require('./makeReducer') _.extend(
  _createEmptyStore(),
  require('../persistence').load().editableRecipe
), {
  'set-prose' : (state, { text }) ->
    return _.defaults { providedProse : text }, state

  'set-provided-recipe-id' : (state, { recipeId }) ->
    return _.defaults { providedRecipeId : recipeId }, state

  'seed-recipe-editor' : (state, { recipe }) ->
    return _.defaults {
      originalRecipeId : recipe.recipeId
      ingredients      : _.map recipe.ingredients, (i) -> {
        tag       : i.tag
        isEditing : false
        display   : _.pick i, 'displayAmount', 'displayUnit', 'displayIngredient'
      }
    }, _.pick(recipe, 'name', 'instructions', 'notes', 'base')

  'start-guided-workflow' : (state, { firstStep }) ->
    return _.defaults {
      currentStep     : firstStep
      currentWorkflow : EditorWorkflow.GUIDED
      name            : state.name.trim()
    }, state

  'start-prose-workflow' : (state, { firstStep }) ->
    # TODO: Seed the other parts of the store here.
    return _.defaults {
      currentStep     : firstStep
      currentWorkflow : EditorWorkflow.FROM_PROSE
    }, state

  'start-id-workflow' : (state, { firstStep }) ->
    # TODO: Load the ID here.
    return _.defaults {
      currentStep     : firstStep
      currentWorkflow : EditorWorkflow.FROM_ID
    }, state

  'set-recipe-editor-workflow' : (state, { workflow }) ->
    return _.defaults { currentWorkflow : workflow }, state

  'set-editable-recipe-page' : (state, { page }) ->
    return _.defaults { currentStep : page }, state

  'set-name' : (state, { name }) ->
    return _.defaults { name }, state

  'delete-ingredient' : (state, { index }) ->
    ingredients = _.clone state.ingredients
    # Ugh side effects.
    ingredients.splice index, 1
    return _.defaults { ingredients }, state

  'add-ingredient' : (state) ->
    return _.defaults {
      ingredients : state.ingredients.concat [{ isEditing : true }]
    }, state

  'commit-ingredient' : (state, { index, rawText, tag }) ->
    ingredients = _.clone state.ingredients
    ingredients[index] = {
      tag
      isEditing : false
      display   : parseIngredientFromText rawText, tag
    }
    return _.defaults { ingredients }, state

  'set-instructions' : (state, { instructions }) ->
    return _.defaults { instructions }, state

  'set-notes' : (state, { notes }) ->
    return _.defaults { notes }, state

  'toggle-base-liquor-tag' : (state, { tag }) ->
    if tag in state.base
      base = _.without state.base, tag
    else
      base = state.base.concat [ tag ]
    return _.defaults { base }, state

  'saving-recipe' : (state) ->
    return _.defaults { isSaving : true }, state

  'saved-recipe' : (state) ->
    return _createEmptyStore()

  'clear-editable-recipe' : (state) ->
    return _createEmptyStore()
}

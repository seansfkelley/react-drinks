_ = require 'lodash'

EditorWorkflow = require '../../recipe-editor/EditorWorkflow'

{ parseIngredientFromText
  parsePartialRecipeFromText } = require '../../utils'

_createDefaultRecipeComponents = -> {
  name             : ''
  ingredients      : []
  instructions     : ''
  notes            : ''
  base             : []
}

_createEmptyStore = -> _.extend {
  currentWorkflow  : null
  currentStep      : null
  editingRecipeId  : null
  isSaving         : false

  # prose
  providedProse    : null

  # id
  providedRecipeId : null
  isLoadingRecipe  : false
  loadedRecipe     : null
  recipeLoadFailed : false

  # guided/editing/prose
}, _createDefaultRecipeComponents()

_convertParsedProseIngredients = (ingredients) ->
  return _.map ingredients, (i) -> {
    tag       : null
    isEditing : false
    display   : i
  }

module.exports = require('./makeReducer') _.extend(
  _createEmptyStore(),
  require('../persistence').load().recipeEditor
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
    parsedRecipe = parsePartialRecipeFromText state.providedProse

    return _.defaults {
      currentStep     : firstStep
      currentWorkflow : EditorWorkflow.PROSE
      ingredients     : _convertParsedProseIngredients parsedRecipe.ingredients
    }, _.omit(parsedRecipe, 'ingredients'), state

  'start-id-workflow' : (state, { firstStep }) ->
    # TODO: Load the ID here.
    return _.defaults {
      currentStep     : firstStep
      currentWorkflow : EditorWorkflow.RECIPE_ID
    }, state

  'set-recipe-editor-workflow' : (state, { workflow }) ->
    return _.defaults { currentWorkflow : workflow }, state

  'set-recipe-editor-step' : (state, { step }) ->
    return _.defaults { currentStep : step }, state

  'set-provided-prose' : (state, { prose }) ->
    return _.defaults {
      providedProse : prose
    }, _createDefaultRecipeComponents(), state

  'compute-recipe-components-from-prose' : (state) ->
    parsedRecipe = parsePartialRecipeFromText state.providedProse

    return _.defaults {
      ingredients : _convertParsedProseIngredients parsedRecipe.ingredients
    }, _.omit(parsedRecipe, 'ingredients'), state

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

  'loading-recipe' : (state) ->
    return _.defaults {
      isLoadingRecipe  : true
      recipeLoadFailed : false
      loadedRecipe     : null
    }, state

  'loaded-provided-recipe' : (state, { recipe }) ->
    return _.defaults {
      isLoadingRecipe  : false
      loadedRecipe     : recipe
    }, state

  'loaded-provided-recipe-failed' : (state) ->
    return _.defaults {
      isLoadingRecipe  : false
      recipeLoadFailed : true
    }, state

  'clear-load-failure-flag' : (state) ->
    return _.defaults { recipeLoadFailed : false }, state

  'clear-editable-recipe' : (state) ->
    return _createEmptyStore()
}

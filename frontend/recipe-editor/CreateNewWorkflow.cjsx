_       = require 'lodash'
React   = require 'react'

ReduxMixin = require '../mixins/ReduxMixin'

store                  = require '../store'
EditableRecipePageType = require '../EditableRecipePageType'

definitions = require '../../shared/definitions'

EditableNamePage        = require './EditableNamePage'
EditableIngredientsPage = require './EditableIngredientsPage'
EditableBaseLiquorPage  = require './EditableBaseLiquorPage'
EditableTextPage        = require './EditableTextPage'
PreviewPage             = require './PreviewPage'

editableRecipeActions = require './editableRecipeActions'
recipeFromStore       = require './recipeFromStore'

CreateNewWorkflow = React.createClass {
  displayName : 'CreateNewWorkflow'

  propTypes :
    onClose : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      editableRecipe : [ 'currentPage', 'ingredients', 'name', 'base', 'saving' ]
    }
  ]

  render : ->
    return switch @state.currentPage

      when EditableRecipePageType.NAME
        <EditableNamePage
          onNext={@_makePageSwitcher(EditableRecipePageType.INGREDIENTS)}
          onClose={@props.onClose}}
        />

      when EditableRecipePageType.INGREDIENTS
        <EditableIngredientsPage
          previousTitle={'"' + @state.name + '"'}
          onPrevious={@_makePageSwitcher(EditableRecipePageType.NAME)}
          onNext={@_makePageSwitcher(EditableRecipePageType.BASE)}
          onClose={@props.onClose}}
        />

      when EditableRecipePageType.BASE
        previousTitle = "#{@state.ingredients.length} ingredient"
        if @state.ingredients.length != 1
          previousTitle += 's'
        <EditableBaseLiquorPage
          previousTitle={previousTitle}
          onPrevious={@_makePageSwitcher(EditableRecipePageType.INGREDIENTS)}
          onNext={@_makePageSwitcher(EditableRecipePageType.TEXT)}
          onClose={@props.onClose}}
        />

      when EditableRecipePageType.TEXT
        if @state.base.length == 1
          previousTitle = "#{definitions.BASE_TITLES_BY_TAG[@state.base[0]]}-based"
        else
          previousTitle = "#{@state.base.length} base liquors"
        <EditableTextPage
          previousTitle={previousTitle}
          onPrevious={@_makePageSwitcher(EditableRecipePageType.BASE)}
          onNext={@_makePageSwitcher(EditableRecipePageType.PREVIEW)}
          onClose={@props.onClose}}
        />

      when EditableRecipePageType.PREVIEW
        <PreviewPage
          previousTitle='Instructions'
          onPrevious={@_makePageSwitcher(EditableRecipePageType.TEXT)}
          onNext={@_finish}
          onClose={@props.onClose}}
          recipe={recipeFromStore store.getState().editableRecipe}
          isSaving={@state.saving}
        />

  _makePageSwitcher : (page) ->
    return =>
      store.dispatch {
        type : 'set-editable-recipe-page'
        page
      }

  _finish : ->
    recipe = recipeFromStore store.getState().editableRecipe
    store.dispatch editableRecipeActions.saveRecipe(recipe)
    .then =>
      @props.onClose()
}

module.exports = CreateNewWorkflow

_       = require 'lodash'
React   = require 'react'

ReduxMixin = require '../mixins/ReduxMixin'

store = require '../store'

definitions = require '../../shared/definitions'

EditorLandingPage = require './EditorLandingPage'
ProseWorkflow = require './ProseWorkflow'

EditorWorkflow        = require './EditorWorkflow'
editableRecipeActions = require './editableRecipeActions'
recipeFromStore       = require './recipeFromStore'

# TODO: make IconButton class?
# TODO: clicking back into ingredients to edit them
# TODO: show what "type of" it is in the final display
# TODO: "oh you put numbers in" (re: instructions); "I didn't know that it would do the numbers as you go in"
# TODO: clicking on something to edit could be nice
# TODO: "done" button is rather far away


###
possible flows are as follows:

landing
  (new)
  -> name -> ingredients -> base -> text -> preview -> (done)

  (prose)
  -> preview
    -> (done)
    -> prose-retry -> preview...
    -> name -> ingredients -> base -> text -> preview...

  (id)
  -> preview -> (done)
  -> id-retry
    -> id-retry ...
    -> preview ...

proposed component hierarchy:

RecipeEditor
  WorkflowChooser
    - use when no workflow is selected
  CreateNewWorkflow
    - no back button
    - doubles as editing interface
  ProseWorkflow
    - no back button
  RecipeIdWorkflow
    - no back button
###



RecipeEditorView = React.createClass {
  displayName : 'RecipeEditorView'

  propTypes :
    onClose : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      editableRecipe : [ 'currentWorkflow' ]
    }
  ]

  render : ->
    childProps =
      onClose   : this.props.onClose
      className : 'recipe-editor'

    return switch @state.currentWorkflow
      when EditorWorkflow.PROSE
        <ProseWorkflow {...childProps}/>
      else
        <EditorLandingPage {...childProps}/>

    # return switch @state.currentStep

    #   when EditableRecipePageType.NAME
    #     <EditableNamePage
    #       onNext={@_makePageSwitcher(EditableRecipePageType.INGREDIENTS)}
    #       onClose={@props.onClose}}
    #     />

    #   when EditableRecipePageType.INGREDIENTS
    #     <EditableIngredientsPage
    #       previousTitle={'"' + @state.name + '"'}
    #       onPrevious={@_makePageSwitcher(EditableRecipePageType.NAME)}
    #       onNext={@_makePageSwitcher(EditableRecipePageType.BASE)}
    #       onClose={@props.onClose}}
    #     />

    #   when EditableRecipePageType.BASE
    #     previousTitle = "#{@state.ingredients.length} ingredient"
    #     if @state.ingredients.length != 1
    #       previousTitle += 's'
    #     <EditableBaseLiquorPage
    #       previousTitle={previousTitle}
    #       onPrevious={@_makePageSwitcher(EditableRecipePageType.INGREDIENTS)}
    #       onNext={@_makePageSwitcher(EditableRecipePageType.TEXT)}
    #       onClose={@props.onClose}}
    #     />

    #   when EditableRecipePageType.TEXT
    #     if @state.base.length == 1
    #       previousTitle = "#{definitions.BASE_TITLES_BY_TAG[@state.base[0]]}-based"
    #     else
    #       previousTitle = "#{@state.base.length} base liquors"
    #     <EditableTextPage
    #       previousTitle={previousTitle}
    #       onPrevious={@_makePageSwitcher(EditableRecipePageType.BASE)}
    #       onNext={@_makePageSwitcher(EditableRecipePageType.PREVIEW)}
    #       onClose={@props.onClose}}
    #     />

    #   when EditableRecipePageType.PREVIEW
    #     <PreviewPage
    #       previousTitle='Instructions'
    #       onPrevious={@_makePageSwitcher(EditableRecipePageType.TEXT)}
    #       onNext={@_finish}
    #       onClose={@props.onClose}}
    #       recipe={recipeFromStore store.getState().editableRecipe}
    #       isSaving={@state.saving}
    #     />

  _makePageSwitcher : (page) ->
    return =>
      store.dispatch {
        type : 'set-editable-recipe-step'
        page
      }

  _finish : ->
    recipe = recipeFromStore store.getState().editableRecipe
    store.dispatch editableRecipeActions.saveRecipe(recipe)
    .then =>
      @props.onClose()
}

module.exports = RecipeEditorView

React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ReduxMixin = require '../mixins/ReduxMixin'

EditorLandingPage = require './EditorLandingPage'
EditorWorkflow    = require './EditorWorkflow'
ProseWorkflow     = require './ProseWorkflow'
RecipeIdWorkflow  = require './RecipeIdWorkflow'
GuidedWorkflow    = require './GuidedWorkflow'

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
    PureRenderMixin
  ]

  render : ->
    childProps = {
      onClose   : @props.onClose
      className : 'recipe-editor'
    }

    return switch @state.currentWorkflow
      when EditorWorkflow.GUIDED
        <GuidedWorkflow {...childProps}/>
      when EditorWorkflow.PROSE
        <ProseWorkflow {...childProps}/>
      when EditorWorkflow.RECIPE_ID
        <RecipeIdWorkflow {...childProps}/>
      else
        <EditorLandingPage {...childProps}/>
}

module.exports = RecipeEditorView

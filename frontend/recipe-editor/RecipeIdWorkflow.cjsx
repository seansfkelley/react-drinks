React = require 'react'

ReduxMixin = require '../mixins/ReduxMixin'

WorkflowStep =
  ID      : 'id'
  PREVIEW : 'preview'

RecipeIdWorkflow = React.createClass {
  displayName : 'RecipeIdWorkflow'

  propTypes :
    onClose   : React.PropTypes.func.isRequired
    className : React.PropTypes.string

  mixins : [
    ReduxMixin {
      editableRecipe : [ 'currentStep', 'providedRecipeId', 'isLoadingRecipe', 'loadedRecipe', 'recipeLoadFailed' ]
    }
  ]

  render : ->
    <div/>
}

RecipeIdWorkflow.FIRST_STEP = WorkflowStep.PREVIEW

module.exports = RecipeIdWorkflow

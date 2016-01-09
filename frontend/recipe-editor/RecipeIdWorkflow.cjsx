React = require 'react'

WorkflowStep =
  ID      : 'id'
  PREVIEW : 'preview'

RecipeIdWorkflow = React.createClass {
  displayName : 'RecipeIdWorkflow'

  propTypes : {}

  render : ->
    <div/>
}

RecipeIdWorkflow.FIRST_STEP = WorkflowStep.PREVIEW

module.exports = RecipeIdWorkflow

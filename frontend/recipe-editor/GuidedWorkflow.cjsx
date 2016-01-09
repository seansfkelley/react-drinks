React = require 'react'

WorkflowStep =
  NAME        : 'name'
  INGREDIENTS : 'ingredients'
  BASE        : 'base'
  TEXT        : 'text'
  PREVIEW     : 'preview'

GuidedWorkflow = React.createClass {
  displayName : 'GuidedWorkflow'

  propTypes : {}

  render : ->
    <div/>
}

GuidedWorkflow.FIRST_STEP = WorkflowStep.INGREDIENTS

module.exports = GuidedWorkflow

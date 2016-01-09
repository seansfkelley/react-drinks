React = require 'react'

WorkflowStep =
  ID      : 'id'
  PREVIEW : 'preview'

FromIdWorkflow = React.createClass {
  displayName : 'FromIdWorkflow'

  propTypes : {}

  render : ->
    <div/>
}

FromIdWorkflow.FIRST_STEP = WorkflowStep.PREVIEW

module.exports = FromIdWorkflow

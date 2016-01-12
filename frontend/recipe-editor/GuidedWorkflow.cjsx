React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

WorkflowStep =
  NAME        : 'name'
  INGREDIENTS : 'ingredients'
  BASE        : 'base'
  TEXT        : 'text'
  PREVIEW     : 'preview'

GuidedWorkflow = React.createClass {
  displayName : 'GuidedWorkflow'

  propTypes : {}

  mixins : [ PureRenderMixin ]

  render : ->
    <div/>
}

GuidedWorkflow.FIRST_STEP = WorkflowStep.INGREDIENTS

module.exports = GuidedWorkflow

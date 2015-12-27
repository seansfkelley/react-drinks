React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

EditableRecipePage = require './EditableRecipePage'

RecipeView = require '../recipes/RecipeView'

PreviewPage = React.createClass {
  displayName : 'PreviewPage'

  propTypes :
    onClose       : React.PropTypes.func.isRequired
    onNext        : React.PropTypes.func
    onPrevious    : React.PropTypes.func
    previousTitle : React.PropTypes.string
    recipe        : React.PropTypes.object
    isSaving      : React.PropTypes.bool

  mixins : [
    PureRenderMixin
  ]

  render : ->
    if @props.isSaving
      nextButton = <div className='next-button fixed-footer'>
        <span className='next-text'>Saving</span>
        <i className='fa fa-refresh fa-spin'/>
      </div>
    else
      nextButton = <div className='next-button fixed-footer' onTouchTap={@props.onNext}>
        <span className='next-text'>Done</span>
        <i className='fa fa-check'/>
      </div>

    <EditableRecipePage
      className='preview-page'
      onClose={@props.onClose}
      onPrevious={@props.onPrevious}
      previousTitle={@props.previousTitle}
    >
      <div className='fixed-content-pane'>
        <RecipeView recipe={@props.recipe}/>
      </div>
      {nextButton}
    </EditableRecipePage>
}

module.exports = PreviewPage

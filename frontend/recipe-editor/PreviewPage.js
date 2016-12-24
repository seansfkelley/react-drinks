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
      nextButton = React.createElement("div", {"className": 'next-button fixed-footer'},
        React.createElement("span", {"className": 'next-text'}, "Saving"),
        React.createElement("i", {"className": 'fa fa-refresh fa-spin'})
      )
    else
      nextButton = React.createElement("div", {"className": 'next-button fixed-footer', "onTouchTap": (@props.onNext)},
        React.createElement("span", {"className": 'next-text'}, "Done"),
        React.createElement("i", {"className": 'fa fa-check'})
      )

    React.createElement(EditableRecipePage, { \
      "className": 'preview-page',  \
      "onClose": (@props.onClose),  \
      "onPrevious": (@props.onPrevious),  \
      "previousTitle": (@props.previousTitle)
    },
      React.createElement("div", {"className": 'fixed-content-pane'},
        React.createElement(RecipeView, {"recipe": (@props.recipe)})
      ),
      (nextButton)
    )
}

module.exports = PreviewPage

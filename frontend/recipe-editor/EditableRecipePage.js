React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

store = require '../store'

NavigationHeader = React.createClass {
  displayName : 'NavigationHeader'

  propTypes :
    onClose       : React.PropTypes.func.isRequired
    previousTitle : React.PropTypes.string
    onPrevious    : React.PropTypes.func

  mixins : [
    PureRenderMixin
  ]

  render : ->
    React.createElement("div", {"className": 'navigation-header fixed-header'},
      (if @props.previousTitle and @props.onPrevious
        React.createElement("div", {"className": 'back-button float-left', "onTouchTap": (@props.onPrevious)},
          React.createElement("i", {"className": 'fa fa-chevron-left'}),
          React.createElement("span", {"className": 'back-button-label'}, (@props.previousTitle))
        )),
      React.createElement("i", {"className": 'fa fa-times float-right', "onTouchTap": (@_close)})
    )

  _close : ->
    store.dispatch {
      type : 'clear-editable-recipe'
    }

    @props.onClose()
}

EditableRecipePage = React.createClass {
  displayName : 'EditableRecipePage'

  propTypes :
    onClose       : React.PropTypes.func.isRequired
    onPrevious    : React.PropTypes.func
    previousTitle : React.PropTypes.string
    className     : React.PropTypes.string

  render : ->
    React.createElement("div", {"className": (classnames 'editable-recipe-page fixed-header-footer', @props.className)},
      React.createElement(NavigationHeader, {"onClose": (@props.onClose), "previousTitle": (@props.previousTitle), "onPrevious": (@props.onPrevious)}),
      (@props.children)
    )
}

module.exports = EditableRecipePage

_          = require 'lodash'
React      = require 'react'
Draggable  = require 'react-draggable'
classnames = require 'classnames'

Deletable = require './Deletable'

List = React.createClass {
  displayName : 'List'

  propTypes :
    emptyText : React.PropTypes.string
    emptyView : React.PropTypes.element

  getDefaultProps : -> {
    emptyText : 'Nothing to see here.'
  }

  render : ->
    if React.Children.count(@props.children) == 0
      if @props.emptyView
        children = @props.emptyView
      else
        children = React.createElement("div", {"className": 'empty-list-text'}, (@props.emptyText))
    else
      children = @props.children

    renderableProps = _.omit @props, 'emptyView', 'emptyText'
    React.createElement("div", Object.assign({},  renderableProps, {"className": (classnames 'list', @props.className)}),
      (children)
    )
}

List.Header = React.createClass {
  displayName : 'List.Header'

  propTypes :
    title : React.PropTypes.string

  render : ->
    if React.Children.count(@props.children) == 0
      children = React.createElement("span", {"className": 'text'}, (@props.title))
    else
      children = @props.children

    renderableProps = _.omit @props, 'title'
    React.createElement("div", Object.assign({},  renderableProps, {"className": (classnames 'list-header', @props.className)}),
      (children)
    )
}

List.ItemGroup = React.createClass {
  displayName : 'List.ItemGroup'

  propTypes : {}

  render : ->
    React.createElement("div", Object.assign({},  @props, {"className": (classnames 'list-group', @props.className)}),
      (@props.children)
    )
}

List.Item = React.createClass {
  displayName : 'List.Item'

  propTypes : {}

  render : ->
    React.createElement("div", Object.assign({},  @props, {"className": (classnames 'list-item', @props.className)}),
      (@props.children)
    )
}

List.DeletableItem = React.createClass {
  displayName : 'List.DeletableItem'

  propTypes :
    onDelete : React.PropTypes.func.isRequired

  render : ->
    renderableProps = _.omit @props, 'onDelete'
    React.createElement(List.Item, Object.assign({},  renderableProps, {"className": (classnames 'deletable-list-item', @props.className)}),
      React.createElement(Deletable, {"onDelete": (@props.onDelete)},
        React.createElement("div", null,
          (@props.children)
        )
      )
    )
}

List.AddableItem = React.createClass {
  displayName : 'List.AddableItem'

  propTypes :
    placeholder : React.PropTypes.string
    onAdd       : React.PropTypes.func.isRequired

  getDefaultProps : -> {
    placeholder : 'Add...'
  }

  getInitialState : -> {
    isEditing : false
    value     : ''
  }

  render : ->
    React.createElement(List.Item, {"className": 'addable-list-item'},
      React.createElement("input", { \
        "onFocus": (@_setEditing),  \
        "onBlur": (@_clearEditing),  \
        "onChange": (@_setValue),  \
        "value": (@state.value),  \
        "placeholder": (@props.placeholder),  \
        "type": 'text',  \
        "autoCorrect": 'off',  \
        "autoCapitalize": 'off',  \
        "autoComplete": 'off',  \
        "spellCheck": 'false',  \
        "ref": 'input'
      }),
      React.createElement("i", {"className": (classnames 'fa fa-plus', { 'enabled' : @state.isEditing or @state.value }), "onTouchTap": (@_add)})
    )

  _setEditing : ->
    @setState { isEditing : false }

  _clearEditing : ->
    @setState {
      value     : @state.value.trim()
      isEditing : false
    }

  _setValue : (e) ->
    @setState { value : e.target.value }

  _add : ->
    @props.onAdd @state.value
}

List.ClassNames =
  HEADERED    : 'headered-list'
  COLLAPSIBLE : 'collapsible-list'

module.exports = List

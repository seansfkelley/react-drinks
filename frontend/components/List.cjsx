# @cjsx React.DOM

_          = require 'lodash'
React      = require 'react'
Draggable  = require 'react-draggable'
classnames = require 'classnames'

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
        children = <div className='empty-list-text'>{@props.emptyText}</div>
    else
      children = @props.children

    renderableProps = _.omit @props, 'emptyView', 'emptyText'
    <div {...renderableProps} className={classnames 'list', @props.className}>
      {children}
    </div>
}

List.Header = React.createClass {
  displayName : 'List.Header'

  propTypes :
    title : React.PropTypes.string

  render : ->
    if React.Children.count(@props.children) == 0
      children = <span className='text'>{@props.title}</span>
    else
      children = @props.children

    renderableProps = _.omit @props, 'title'
    <div {...renderableProps} className={classnames 'list-header', @props.className}>
      {children}
    </div>
}

List.ItemGroup = React.createClass {
  displayName : 'List.ItemGroup'

  propTypes : {}

  render : ->
    <div {...@props} className={classnames 'list-group', @props.className}>
      {@props.children}
    </div>
}

List.Item = React.createClass {
  displayName : 'List.Item'

  propTypes : {}

  render : ->
    <div {...@props} className={classnames 'list-item', @props.className}>
      {@props.children}
    </div>
}

DELETABLE_WIDTH = 80

List.DeletableItem = React.createClass {
  displayName : 'List.DeletableItem'

  propTypes :
    onDelete : React.PropTypes.func.isRequired

  getInitialState : ->
    return {
      left : 0
    }

  render : ->
    renderableProps = _.omit @props, 'onDelete'
    left = DELETABLE_WIDTH - Math.abs(@state.left)
    <Draggable axis='x' onDrag={@_clampDrag} onStop={@_onDragEnd} ref='draggable'>
      <List.Item {...renderableProps} className={classnames 'deletable', @props.className}>
        {@props.children}
        <div
          className='delete-button'
          style={{
            width          : DELETABLE_WIDTH
            right          : @state.left
            WebkitClipPath : "polygon(#{left}px 0, #{left}px 100%, 100% 100%, 100% 0)"
          }}
          onTouchTap={@_onDelete}
        >
          <span className='text'>Delete</span>
        </div>
      </List.Item>
    </Draggable>

  _onDelete : (e) ->
    e.stopPropagation()
    @props.onDelete()

  _clampDrag : (event, { position }) ->
    if position.left > 0
      @refs.draggable.setState { clientX : 0 }
      @setState { left : 0 }
    else if position.left < -DELETABLE_WIDTH
      @refs.draggable.setState { clientX : -DELETABLE_WIDTH }
      @setState { left : -DELETABLE_WIDTH }
    else
      @setState { left : position.left }

  # TODO: Make this animate.
  _onDragEnd : (event, { position }) ->
    if position.left < -DELETABLE_WIDTH / 2
      @refs.draggable.setState { clientX : -DELETABLE_WIDTH }
      @setState { left : -DELETABLE_WIDTH }
    else
      @refs.draggable.setState { clientX : 0 }
      @setState { left : 0 }
}

List.headerify = ({ nodes, computeHeaderData, Header, ItemGroup }) ->
  Header    ?= List.Header
  ItemGroup ?= List.ItemGroup

  groupedNodes = []
  for n, i in nodes
    # computeHeaderData must return an object with at least a 'key' field.
    newHeaderData = computeHeaderData n, i
    group = _.last groupedNodes
    if not group? or not _.isEqual(group.headerData, newHeaderData)
      group = {
        headerData : newHeaderData
        items      : []
      }
      groupedNodes.push group
    group.items.push n

  return _.chain groupedNodes
    .map ({ headerData, items }) ->
      return [
        <Header {...headerData}/>
        <ItemGroup {...headerData} key={'group-' + headerData.key}>{items}</ItemGroup>
      ]
    .flatten()
    .value()

List.ClassNames =
  HEADERED    : 'headered-list'
  COLLAPSIBLE : 'collapsible-list'

module.exports = List

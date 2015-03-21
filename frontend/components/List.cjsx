# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

ClassNameMixin = require '../mixins/ClassNameMixin'

List = {}

List.Header = React.createClass {
  displayName : 'List.Header'

  mixins : [
    ClassNameMixin
  ]

  render : ->
    if React.Children.count(@props.children) == 0
      children = <span className='text'>{@props.title}</span>
    else
      children = @props.children

    renderableProps = _.omit @props, 'title'
    <div {...renderableProps} className={@getClassName 'list-header'}>
      {children}
    </div>
}

List.ItemGroup = React.createClass {
  displayName : 'List.ItemGroup'

  mixins : [
    ClassNameMixin
  ]

  render : ->
    <div {...@props} className={@getClassName 'list-group'}>
      {@props.children}
    </div>
}

List.Item = React.createClass {
  displayName : 'List.Item'

  mixins : [
    ClassNameMixin
  ]

  render : ->
    <div {...@props} className={@getClassName 'list-item'}>
      {@props.children}
    </div>
}

List.List = React.createClass {
  displayName : 'List.List'

  propTypes :
    emptyText : React.PropTypes.string
    emptyView : React.PropTypes.element

  mixins : [
    ClassNameMixin
  ]

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
    <div {...renderableProps} className={@getClassName 'list'}>
      {children}
    </div>
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

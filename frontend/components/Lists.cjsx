# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

ClassNameMixin = require '../mixins/ClassNameMixin'

Lists = {}

Lists.ListHeader = React.createClass {
  displayName : 'ListHeader'

  mixins : [
    ClassNameMixin
  ]

  render : ->
    if React.Children.count(@props.children) == 0
      children = <span className='text'>{@props.title}</span>
    else
      children = @props.children

    <div className={@getClassName 'list-header'}>
      {children}
    </div>
}

Lists.ListItem = React.createClass {
  displayName : 'ListItem'

  mixins : [
    ClassNameMixin
  ]

  render : ->
    <div {...@props} className={@getClassName 'list-item'}>
      {@props.children}
    </div>
}

Lists.List = React.createClass {
  displayName : 'List'

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

    <div {...@props} className={@getClassName 'list'}>
      {children}
    </div>
}

Lists.headerify = ({ nodes, computeHeaderData, Header }) ->
  Header ?= Lists.ListHeader

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
        <div className='list-group' key={'group-' + headerData.key}>{items}</div>
      ]
    .flatten()
    .value()

Lists.ClassNames =
  HEADERED    : 'headered-list'
  COLLAPSIBLE : 'collapsible'

module.exports = Lists

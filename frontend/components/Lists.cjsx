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

  headerData = null
  headeredNodes = []
  for n, i in nodes
    newHeaderData = computeHeaderData n, i
    if not _.isEqual(headerData, newHeaderData)
      headeredNodes.push <Header {...newHeaderData}/>
      headerData = newHeaderData
    headeredNodes.push n
  return headeredNodes

Lists.HeaderedList = React.createClass {
  displayName : 'Lists.HeaderedList'

  mixins : [
    ClassNameMixin
  ]

  render : ->
    <Lists.List {...@props} className={@getClassName 'headered-list'}>
      {@props.children}
    </Lists.List>
}

module.exports = Lists

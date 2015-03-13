# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

ClassNameMixin = require '../mixins/ClassNameMixin'

Lists = {}

ListHeader = React.createClass {
  displayName : 'ListHeader'

  render : ->
    <div className='list-header'>
      <span className='text'>{@props.title}</span>
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

  mixins : [
    ClassNameMixin
  ]

  getDefaultProps : -> {
    emptyText : 'Nothing to see here.'
  }

  render : ->
    if React.Children.count(@props.children) == 0
      children = <div className='empty-list-text'>{@props.emptyText}</div>
    else
      children = @props.children

    <div {...@props} className={@getClassName 'list'}>
      {children}
    </div>
}

Lists.HeaderedList = React.createClass {
  displayName : 'HeaderedList'

  propTypes :
    emptyText      : React.PropTypes.string
    titleExtractor : React.PropTypes.func.isRequired

  mixins : [
    ClassNameMixin
  ]

  render : ->
    children = []
    lastTitle = null
    React.Children.forEach @props.children, (child, i) =>
      title = @props.titleExtractor child, i
      if title != lastTitle
        lastTitle = title
        children.push <ListHeader title={title} key={'header-' + title} ref={'header-' + title}/>
      children.push child

    <Lists.List className={@getClassName 'headered-list'} emptyText={@props.emptyText}>
      {children}
    </Lists.List>
}

module.exports = Lists

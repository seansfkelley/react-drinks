# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

Lists = {}

ListHeader = React.createClass {
  displayName : 'ListHeader'

  render : ->
    <div className='list-header'>
      <span className='text'>{@props.title}</span>
    </div>
}

Lists.HeaderedList = React.createClass {
  displayName : 'HeaderedList'

  propTypes :
    classNames     : React.PropTypes.string
    emptyText      : React.PropTypes.string
    titleExtractor : React.PropTypes.func.isRequired

  getDefaultProps : -> {
    classNames : ''
  }

  render : ->
    children = []
    lastTitle = null
    React.Children.forEach @props.children, (child, i) =>
      title = @props.titleExtractor child, i
      if title != lastTitle
        lastTitle = title
        children.push <ListHeader title={title} key={'header-' + title} ref={'header-' + title}/>
      children.push child

    # TODO: Pass the empty text through.
    # TODO: Will React have a null clobber a default if the passed null is explicit? Or can I blindly pass in @props.emptyText?
    <Lists.List className={'headered-list ' + @props.classNames}>
      {children}
    </Lists.List>
}

Lists.List = React.createClass {
  displayName : 'List'

  propTypes :
    className : React.PropTypes.string
    emptyText : React.PropTypes.string

  getDefaultProps : -> {
    className : ''
    emptyText : 'Nothing to see here.'
  }

  render : ->
    className = 'list ' + @props.className
    if React.Children.count(@props.children) == 0
      children = <div className='empty-list-text'>{@props.emptyText}</div>
    else
      children = @props.children

    <div {...@props} className={className}>
      {children}
    </div>
}

Lists.ListItem = React.createClass {
  displayName : 'ListItem'

  render : ->
    className = 'list-item ' + (@props.className ? '')
    <div {...@props} className={className}>
      {@props.children}
    </div>
}

module.exports = Lists

# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

ListHeader = require './ListHeader'

HeaderedList = React.createClass {
  displayName : 'HeaderedList'

  propTypes :
    classNames     : React.PropTypes.string
    emptyText      : React.PropTypes.string
    titleExtractor : React.PropTypes.func.isRequired

  getDefaultProps : -> {
    classNames : 'default-headered-list'
    emptyText  : 'Nothing to see here.'
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

    if children.length == 0
      children.push <div className='empty-list-text' key='empty'>Nothing to see here.</div>

    <div className={'headered-list ' + @props.classNames}>
      {children}
    </div>
}

HeaderedList.ListItem = React.createClass {
  render : ->
    className = 'list-item ' + (@props.className ? '')
    <div {...@props} className={className}>
      {@props.children}
    </div>
}

module.exports = HeaderedList

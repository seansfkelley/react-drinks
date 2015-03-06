# @cjsx React.DOM

React = require 'react'

PaginatedViewHeader = React.createClass {
  render : ->
    if @props.index > 0
      leftControl =
        <div className='paginated-control left' onClick={@_onControlClick.bind(this, 'left')}>
          <i className='fa fa-chevron-left'/>
          <span className='page-title'>{@props.pages[@props.index - 1].title}</span>
        </div>
    else
      leftControl = <div className='paginated-control left'/>

    if @props.index < @props.pages.length - 1
      rightControl =
        <div className='paginated-control right' onClick={@_onControlClick.bind(this, 'right')}>
          <span className='page-title'>{@props.pages[@props.index + 1].title}</span>
          <i className='fa fa-chevron-right'/>
        </div>
    else
      rightControl = <div className='paginated-control right'/>

    <div className='paginated-bar fixed-header-bar'>
      {leftControl}
      <div className='paginated-title'>{@props.pages[@props.index].title}</div>
      {rightControl}
    </div>

  _onControlClick : (direction) ->
    if direction == 'left'
      @props.setIndex @props.index - 1
    else
      @props.setIndex @props.index + 1
}

PaginatedView = React.createClass {
  getInitialState : ->
    return {
      index : 0
    }

  render : ->
    <div className='paginated-view fixed-header-container'>
      <PaginatedViewHeader setIndex={@_setIndex} index={@state.index} pages={@props.pages}/>
      <div className='paginated-view-content fixed-content-pane'>
        {@props.pages[@state.index].content}
      </div>
    </div>

  _setIndex : (index) ->
    @setState { index }
}

module.exports = PaginatedView

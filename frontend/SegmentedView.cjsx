# @cjsx React.DOM

React = require 'react'

SegmentedViewHeader = React.createClass {
  render : ->
    if @props.index > 0
      leftControl =
        <div className='segment-control left' onClick={@_onControlClick.bind(this, 'left')}>
          <i className='fa fa-chevron-left'/>
          <span className='label'>{@props.segments[@props.index - 1].title}</span>
        </div>
    else
      leftControl = <div className='segment-control left'/>

    if @props.index < @props.segments.length - 1
      rightControl =
        <div className='segment-control right' onClick={@_onControlClick.bind(this, 'right')}>
          <span className='label'>{@props.segments[@props.index + 1].title}</span>
          <i className='fa fa-chevron-right'/>
        </div>
    else
      rightControl = <div className='segment-control right'/>

    <div className='segmented-bar'>
      {leftControl}
      <div className='segment-title'>{@props.segments[@props.index].title}</div>
      {rightControl}
    </div>

  _onControlClick : (direction) ->
    if direction == 'left'
      @props.setIndex @props.index - 1
    else
      @props.setIndex @props.index + 1
}

SegmentedView = React.createClass {
  getInitialState : ->
    return {
      index : 0
    }

  render : ->
    <div className='segmented-view'>
      <SegmentedViewHeader setIndex={@_setIndex} index={@state.index} segments={@props.segments}/>
      {@props.segments[@state.index].content}
    </div>

  _setIndex : (index) ->
    @setState { index }
}

module.exports = SegmentedView

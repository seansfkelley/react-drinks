# @cjsx React.DOM

React = require 'react'

SegmentedViewHeader = React.createClass {
  render : ->
    leftControlClasses = 'segment-control left'
    if @props.index == 0
      leftControlClasses += ' hidden'

    rightControlClasses = 'segment-control right'
    if @props.index == @props.segments.length - 1
      rightControlClasses += ' hidden'

    <div className='segmented-bar'>
      <div className={leftControlClasses} onClick={@_onControlClick.bind(this, 'left')}>
        <i className='fa fa-chevron-left'/>
      </div>
      <div className='segment-title'>{@props.segments[@props.index].title}</div>
      <div className={rightControlClasses} onClick={@_onControlClick.bind(this, 'right')}>
        <i className='fa fa-chevron-right'/>
      </div>
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

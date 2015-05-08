_              = require 'lodash'
React          = require 'react/addons'
classnames     = require 'classnames'
ReactSwipeable = require 'react-swipeable'

_clamp = (x, min, max) ->
  return Math.max min, Math.min(x, max)

IntertialSwipable = React.createClass {
  displayName : 'IntertialSwipable'

  propTypes :
    onSwiping         : React.PropTypes.func
    onSwiped          : React.PropTypes.func
    getProposedTarget : React.PropTypes.func

  getInitialState : -> {
    startTime : null
    startX    : null
    lastX     : null
  }

  render : ->
    <div
      onTouchStart={@_onTouchStart}
      onTouchMove={@_onTouchMove}
      onTouchEnd={@_onTouchEnd}
      className={classnames 'inertial-swipable', @props.className}
    >
      {@props.children}
    </div>

  _cancel : ->
    if @_animFrame?
      cancelAnimationFrame @_animFrame
      @props.onSwiped
      @_animFrame = null

  _setStartTime : ->
    if not @state.startTime?
      @setState { startTime : Date.now() }

  _onTouchStart : (e) ->
    if e.touches.length > 1
      return

    @setState {
      startTime : Date.now()
      startX    : e.touches[0].clientX
      lastX     : e.touches[0].clientX
    }

  _onTouchMove : (e) ->
    if e.touches.length > 1
      return

    @props.onSwiping e.touches[0].clientX - @state.lastX

    @setState {
      lastX : e.touches[0].clientX
    }

  _onTouchEnd : (e) ->
    if e.touches.length > 1
      return

    @props.onSwiping e.touches[0].clientX - @state.lastX

    # TODO: Compute the instantaneous velocity rather than the average.
    velocity = 1000 * (e.touches[0].clientX - @state.startX) / (Date.now() - @state.startTime)

    autoScrollStartTime = Date.now()

    amplitude = 0.5 * velocity

    targetOffset = -x + amplitude
    if @props.getProposedTarget
      targetOffset = @props.getProposedTarget targetOffset

    timeConstant = 325

    _step = =>
      elapsed = Date.now() - autoScrollStartTime
      delta = -amplitude * Math.exp(-elapsed / timeConstant)
      if delta < -1 or delta > 1
        @props.onSwiping delta
        @_animFrame = requestAnimationFrame _step
      else
        @props.onSwiped()

    @_animFrame = requestAnimationFrame _step
    @setState @getInitialState()

}

Swipable = React.createClass {
  displayName : 'Swipable'

  propTypes :
    initialIndex  : React.PropTypes.number
    onSlideChange : React.PropTypes.func

  getInitialState : ->
    zeroes = _.map _.range(React.Children.count(@props.children)), -> 0
    return {
      index       : @props.initialIndex ? 0
      wrapperWidth: 0
      itemWidths  : zeroes
      itemOffsets : zeroes
      delta       : 0
    }

  render : ->
    offset = -@state.itemOffsets[@state.index] + (@state.wrapperWidth - @state.itemWidths[@state.index]) / 2 + @state.delta

    # <ReactSwipeable
    #   onSwipingLeft={@_onSwipingLeft}
    #   onSwipingRight={@_onSwipingRight}
    #   onSwiped={@_onSwiped}
    #   className={classnames 'viewport-container', @props.className}
    # >
    # </ReactSwipeable>
    <IntertialSwipable
      onSwiping={@_onSwiping}
      onSwiped={@_onSwiped}
      getProposedTarget={@_getProposedTarget}
      className={classnames 'viewport-container', @props.className}
    >
      <div
        onTouchTap={@_onTouchTap}
        className='sliding-container'
        ref='slidingContainer'
        style={{
          WebkitTransform : "translateX(#{offset}px) translateZ(0)" # Hardware acceleration.
          transform       : "translateX(#{offset}px)"
        }}
      >
        {@props.children}
      </div>
    </IntertialSwipable>

  componentDidMount: ->
    wrapperWidth = React.findDOMNode(@refs.slidingContainer).offsetWidth
    itemWidths   = _.pluck React.findDOMNode(@refs.slidingContainer).children, 'offsetWidth'
    itemOffsets  = _.chain itemWidths
      .reduce ((offsets, width) ->
        offsets.push _.last(offsets) + width
        return offsets
      ), [ 0 ]
      .initial()
      .value()
    @setState { wrapperWidth, itemWidths, itemOffsets }

  # _addResistance : (delta) ->
  #   clampedDelta = Math.min Math.abs(delta), 500
  #   return delta * (2 - Math.sqrt(clampedDelta / 500)) / 3

  _onTouchTap : (e) ->
    target = e.target
    slidingContainer = React.findDOMNode @refs.slidingContainer
    while target.parentNode != slidingContainer
      target = target.parentNode
    @_finishSwipe _.indexOf(slidingContainer.children, target)

  _onSwiping : (delta) ->
    currentBaseOffset = @state.itemOffsets[@state.index]
    delta = _clamp delta, currentBaseOffset - _.last(@state.itemOffsets), currentBaseOffset
    @setState { delta }

  _getProposedTarget : (delta) ->
    proposedTarget = @state.itemOffsets[@state.index] - delta
    offsetTargets = _.chain()
      .range(@state.itemOffsets.length)
      .map (i) => @state.itemOffsets[i] - @state.itemWidths[i] / 2
      .value()
    # Erm, why is this -1?
    targetIndex  = _.sortedIndex(offsetTargets, proposedTarget) - 1
    if targetIndex == -1
      targetIndex = 0
    return @state.itemOffsets[@state.index] - @state.itemOffsets[targetIndex]

  _onSwiped : (delta) ->
    proposedTarget = @state.itemOffsets[@state.index] - delta
    offsetTargets = _.chain()
      .range(@state.itemOffsets.length)
      .map (i) => @state.itemOffsets[i] - @state.itemWidths[i] / 2
      .value()
    # Erm, why is this -1?
    targetIndex  = _.sortedIndex(offsetTargets, proposedTarget) - 1
    if targetIndex == -1
      targetIndex = 0

    @_finishSwipe targetIndex

  _finishSwipe : (index) ->
    @setState {
      index
      delta : 0
    }
    @props.onSlideChange index
}

module.exports = Swipable

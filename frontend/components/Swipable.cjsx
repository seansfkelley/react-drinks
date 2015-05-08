_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

_clamp = (x, min, max) ->
  return Math.max min, Math.min(x, max)

TIME_CONSTANT = 325

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

  _onTouchStart : (e) ->
    if e.touches.length > 1
      return

    if @_animFrame?
      cancelAnimationFrame @_animFrame

    @setState {
      startTime : Date.now()
      startX    : e.touches[0].clientX
      lastX     : e.touches[0].clientX
    }

  _onTouchMove : (e) ->
    if e.touches.length > 1
      return

    @props.onSwiping e.changedTouches[0].clientX - @state.lastX
    @setState {
      lastX : e.changedTouches[0].clientX
    }

  _onTouchEnd : (e) ->
    if e.touches.length > 1
      return

    @props.onSwiping e.changedTouches[0].clientX - @state.lastX

    totalSwipeDelta     = e.changedTouches[0].clientX - @state.startX
    # TODO: Compute the instantaneous velocity rather than the average.
    velocity            = 1000 * totalSwipeDelta / (Date.now() - @state.startTime)
    autoScrollStartTime = Date.now()
    amplitude           = 0.3 * velocity

    if @props.getProposedTarget
      amplitude = -@props.getProposedTarget(-amplitude)

    amplitude = Math.round amplitude

    console.log { amplitude }

    lastDelta = -amplitude
    _step = =>
      elapsed = Date.now() - autoScrollStartTime
      delta = -amplitude * Math.exp(-elapsed / TIME_CONSTANT)
      if delta < -1 or delta > 1
        console.log { amplitudeDelta : delta - lastDelta }
        @props.onSwiping delta - lastDelta
        lastDelta = delta
        @_animFrame = requestAnimationFrame _step
      else
        # @props.onSwiping targetOffset - lastX
        @props.onSwiped()
        delete @_animFrame

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
      wrapperWidth: 0
      itemWidths  : zeroes
      itemOffsets : zeroes
      delta       : 0
    }

  _getIndexForDelta : (delta) ->
    shiftedOffsets = _.chain()
      .range(@state.itemOffsets.length)
      .map (i) => @state.itemOffsets[i] - @state.itemWidths[i] / 2
      .value()
    # Why is this -1 again?
    return Math.max 0, _.sortedIndex(shiftedOffsets, delta) - 1

  render : ->
    invertedDelta = _.last(@state.itemOffsets) - @state.delta
    offset = invertedDelta - (@state.wrapperWidth - @state.itemWidths[@_getIndexForDelta(invertedDelta)]) / 2

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
          WebkitTransform : "translateX(#{-offset}px) translateZ(0)" # Hardware acceleration.
          transform       : "translateX(#{-offset}px)"
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
    delta = itemOffsets[@props.initialIndex ? 0]
    @setState { wrapperWidth, itemWidths, itemOffsets, delta }

  _onTouchTap : (e) ->
    target = e.target
    slidingContainer = React.findDOMNode @refs.slidingContainer
    while target.parentNode != slidingContainer
      target = target.parentNode
    @_finishSwipe _.indexOf(slidingContainer.children, target)

  _onSwiping : (delta) ->
    console.log { delta : _clamp @state.delta + delta, 0, _.last(@state.itemOffsets) }
    @setState {
      delta : _clamp @state.delta + delta, 0, _.last(@state.itemOffsets)
    }

  _getProposedTarget : (targetDelta) ->
    proposedTarget = @state.delta - targetDelta
    targetIndex = @_getIndexForDelta proposedTarget
    if targetIndex == -1
      targetIndex = 0
    console.log { stateDelta : @state.delta, targetIndex, proposedTarget, targetDelta, result : @state.delta - @state.itemOffsets[targetIndex], itemOffsets : @state.itemOffsets }
    return @state.delta - @state.itemOffsets[targetIndex]

  _onSwiped : (delta) ->
    console.log @state.itemOffsets
    console.log @_getIndexForDelta(_.last(@state.itemOffsets) - @state.delta)

  _finishSwipe : (index) ->
    @setState {
      index
      delta : 0
    }
    @props.onSlideChange index
}

module.exports = Swipable

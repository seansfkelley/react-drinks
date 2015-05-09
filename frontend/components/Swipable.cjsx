_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

_clamp = (x, min, max) ->
  return Math.max min, Math.min(x, max)

TIME_CONSTANT = 150

IntertialSwipable = React.createClass {
  displayName : 'IntertialSwipable'

  propTypes :
    onSwiping  : React.PropTypes.func
    onSwiped   : React.PropTypes.func
    fenceposts : React.PropTypes.array

  getInitialState : -> {
    trueDelta           : 0
    delta               : 0
    lastX               : null
    lastTrackedTime     : Date.now()
    lastTrackedDelta    : 0
    lastTrackedVelocity : 0
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
      lastX               : e.touches[0].clientX
      lastTrackedTime     : Date.now()
      lastTrackedDelta    : @state.delta
      lastTrackedVelocity : 0
    }

    @_interval = setInterval @_trackVelocity, 50

    e.preventDefault()

  _trackVelocity : ->
    now = Date.now()
    elapsed = now - @state.lastTrackedTime

    v = 1000 * (@state.delta - @state.lastTrackedDelta) / (1 + elapsed)

    @setState {
      lastTrackedTime     : now
      lastTrackedDelta    : @state.delta
      lastTrackedVelocity : 0.8 * v + 0.2 * @state.lastTrackedVelocity
    }

    console.log @state

  _onTouchMove : (e) ->
    if e.touches.length > 1
      return

    trueDelta = @state.trueDelta - (e.changedTouches[0].clientX - @state.lastX)
    delta = @_computeResistance trueDelta

    @setState {
      trueDelta
      delta
      lastX : e.changedTouches[0].clientX
    }

    console.log 'manual', {trueDelta,delta}

    @props.onSwiping delta

    e.preventDefault()

  _computeResistance : (trueDelta) ->
    if trueDelta > _.last(@props.fenceposts)
      delta = trueDelta - _.last(@props.fenceposts)
      return _.last(@props.fenceposts) + Math.sqrt(delta) * 4
    else if trueDelta < 0
      delta = trueDelta
      return -Math.sqrt(Math.abs(delta)) * 4
    else
      return trueDelta

  _uncomputeResistance : (delta) ->
    if delta > _.last(@props.fenceposts)
      trueDelta = delta - _.last(@props.fenceposts)
      return _.last(@props.fenceposts) + Math.pow(trueDelta / 4, 2)
    else if delta < 0
      trueDelta = delta
      return -Math.pow(Math.abs(trueDelta) / 4, 2)
    else
      return delta

  # Clean this code the fuck up.
  _onTouchEnd : (e) ->
    if e.touches.length > 1
      return

    e.preventDefault()

    clearInterval @_interval

    @_onTouchMove e
    @setState {
      lastX        : null
      stashedTime  : null
      stashedDelta : null
    }

    @_autoScrollToDerivedDelta()

  _deltaInRange : ->
    return 0 < @state.delta < _.last(@props.fenceposts)

  _autoScrollToDerivedDelta : ->
    if not @_deltaInRange()
      @_bounceBackIfNecessary()
      return

    amplitude = 0.3 * @state.lastTrackedVelocity
    console.log @state.lastTrackedVelocity
    target    = @state.trueDelta + amplitude

    absAmp = Math.min Math.abs(amplitude), 600

    autoScrollStartTime = Date.now()
    _step = =>
      elapsed = Date.now() - autoScrollStartTime
      delta = -amplitude * Math.exp(-elapsed / TIME_CONSTANT)
      # console.log delta
      if delta < -1 or delta > 1
        trueDelta = target + delta
        delta = @_computeResistance trueDelta
        @setState { trueDelta, delta }
        console.log 'automatic1', {
          trueDelta
          delta
        }
        @props.onSwiping delta
        if Math.abs(delta - @state.delta) < 1 and not @_deltaInRange()
          @_bounceBackIfNecessary()
          delete @_animFrame
        else
          @_animFrame = requestAnimationFrame _step
      else
        delete @_animFrame

    @_animFrame = requestAnimationFrame _step

  _bounceBackIfNecessary : ->
    if @state.delta < 0
      amplitude = -@state.delta
      target = 0
    else if @state.delta > _.last(@props.fenceposts)
      amplitude = -(@state.delta - _.last(@props.fenceposts))
      target = _.last @props.fenceposts
    else
      return

    console.log {amplitude, target}

    autoScrollStartTime = Date.now()
    _step = =>
      elapsed = Date.now() - autoScrollStartTime
      delta2 = -amplitude * Math.exp(-elapsed / TIME_CONSTANT)
      # console.log delta
      if delta2 < -1 or delta2 > 1
        delta = target + delta2
        trueDelta = @_uncomputeResistance delta
        @setState { trueDelta, delta }
        console.log 'automatic2', {
          trueDelta
          delta
        }
        @props.onSwiping delta
        @_animFrame = requestAnimationFrame _step
      else
        @setState {
          trueDelta : target
          delta     : target
        }
        @props.onSwiping target
        delete @_animFrame

    @_animFrame = requestAnimationFrame _step
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
    # return _.sortedIndex(@state.itemOffsets, delta)
    shiftedOffsets = _.chain()
      .range(@state.itemOffsets.length)
      .map (i) => @state.itemOffsets[i] - @state.itemWidths[i] / 2
      .value()
    # Why is this -1 again?
    return Math.max 0, _.sortedIndex(shiftedOffsets, delta) - 1

  render : ->
    # TODO: Fixed these goddamned sign issues. What does this delta actually represent?!
    # invertedDelta = _.last(@state.itemOffsets) - @state.delta
    # offset = invertedDelta - (@state.wrapperWidth - @state.itemWidths[@_getIndexForDelta(invertedDelta)]) / 2
    offset = @state.delta

    <IntertialSwipable
      onSwiping={@_onSwiping}
      onSwiped={@_onSwiped}
      fenceposts={@state.itemOffsets}
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
    delta = 0 # itemOffsets[@props.initialIndex ? 0]
    @setState { wrapperWidth, itemWidths, itemOffsets, delta }

  _onTouchTap : (e) ->
    target = e.target
    slidingContainer = React.findDOMNode @refs.slidingContainer
    while target.parentNode != slidingContainer
      target = target.parentNode
    @_finishSwipe _.indexOf(slidingContainer.children, target)

  _onSwiping : (delta) ->
    @setState { delta }

  _snapToDelta : (targetDelta) ->
    proposedTarget = @state.delta - targetDelta
    targetIndex = @_getIndexForDelta proposedTarget
    if targetIndex == -1
      targetIndex = 0
    return @state.delta - @state.itemOffsets[targetIndex]

  _onSwiped : (delta) ->
    console.log @_getIndexForDelta(_.last(@state.itemOffsets) - @state.delta)

  _finishSwipe : (index) ->
    @setState {
      index
      delta : 0
    }
    @props.onSlideChange index
}

module.exports = Swipable

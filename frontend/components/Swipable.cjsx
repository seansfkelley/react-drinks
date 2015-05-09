_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

assert = require '../../shared/tinyassert'

_clamp = (x, min, max) ->
  return Math.max min, Math.min(x, max)

class IntertialSwipeLogicBox
  constructor : ({ @itemOffsets, @onChangeDelta }) ->
    assert @itemOffsets
    assert @onChangeDelta

    _.extend @, {
      trueDelta           : 0
      delta               : 0
      lastX               : null
      lastTrackedTime     : Date.now()
      lastTrackedDelta    : 0
      lastTrackedVelocity : 0
    }

  _set : (fields) =>
    if fields.delta? and fields.delta != @delta
      @onChangeDelta fields.delta

    _.extend @, fields

  onTouchStart : (e) =>
    if @_animFrame?
      cancelAnimationFrame @_animFrame

    @_set {
      lastX               : e.touches[0].clientX
      lastTrackedTime     : Date.now()
      lastTrackedDelta    : @delta
      lastTrackedVelocity : 0
    }

    @_interval = setInterval @_trackVelocity, 50

  _trackVelocity : =>
    now = Date.now()
    elapsed = now - @lastTrackedTime

    v = 1000 * (@delta - @lastTrackedDelta) / (1 + elapsed)

    @_set {
      lastTrackedTime     : now
      lastTrackedDelta    : @delta
      lastTrackedVelocity : 0.8 * v + 0.2 * @lastTrackedVelocity
    }

  _computeResistance : (trueDelta) =>
    if trueDelta > _.last(@itemOffsets)
      delta = trueDelta - _.last(@itemOffsets)
      return _.last(@itemOffsets) + Math.sqrt(delta) * 4
    else if trueDelta < 0
      delta = trueDelta
      return -Math.sqrt(Math.abs(delta)) * 4
    else
      return trueDelta

  _uncomputeResistance : (delta) =>
    if delta > _.last(@itemOffsets)
      trueDelta = delta - _.last(@itemOffsets)
      return _.last(@itemOffsets) + Math.pow(trueDelta / 4, 2)
    else if delta < 0
      trueDelta = delta
      return -Math.pow(Math.abs(trueDelta) / 4, 2)
    else
      return delta

  onTouchMove : (e) =>
    trueDelta = @trueDelta - (e.changedTouches[0].clientX - @lastX)
    delta = @_computeResistance trueDelta

    @_set {
      trueDelta
      delta
      lastX : e.changedTouches[0].clientX
    }

  onTouchEnd : (e) =>
    clearInterval @_interval

    @onTouchMove e
    @_set {
      lastX        : null
      stashedTime  : null
      stashedDelta : null
    }

    @_autoScrollToDerivedDelta()

  _deltaInRange : =>
    return 0 < @delta < _.last(@itemOffsets)

  _autoScrollToDerivedDelta : ->
    if not @_deltaInRange()
      @_bounceBackIfNecessary()
      return

    amplitude = 0.3 * @lastTrackedVelocity
    # console.log @state.lastTrackedVelocity
    target    = @trueDelta + amplitude

    autoScrollStartTime = Date.now()
    _step = =>
      elapsed = Date.now() - autoScrollStartTime
      delta2 = -amplitude * Math.exp(-elapsed / TIME_CONSTANT)
      # console.log delta
      if delta2 < -1 or delta2 > 1
        trueDelta = target + delta2
        delta = @_computeResistance trueDelta
        # console.log 'automatic1', {
        #   trueDelta
        #   delta
        # }
        # console.log Math.abs(delta - @state.delta)
        if Math.abs(delta - @delta) < 5 and not @_deltaInRange()
          @_bounceBackIfNecessary()
          delete @_animFrame
        else
          @_animFrame = requestAnimationFrame _step

        @_set { trueDelta, delta }
      else
        delete @_animFrame

    @_animFrame = requestAnimationFrame _step

  _bounceBackIfNecessary : ->
    if @delta < 0
      amplitude = -@delta
      target = 0
    else if @delta > _.last(@itemOffsets)
      amplitude = -(@delta - _.last(@itemOffsets))
      target = _.last @itemOffsets
    else
      return

    # console.log {amplitude, target}

    autoScrollStartTime = Date.now()
    _step = =>
      elapsed = Date.now() - autoScrollStartTime
      delta2 = -amplitude * Math.exp(-elapsed / TIME_CONSTANT)
      # console.log delta
      if delta2 < -1 or delta2 > 1
        delta = target + delta2
        trueDelta = @_uncomputeResistance delta
        @_set { trueDelta, delta }
        # console.log 'automatic2', {
        #   trueDelta
        #   delta
        # }
        @_animFrame = requestAnimationFrame _step
      else
        @_set {
          trueDelta : target
          delta     : target
        }
        delete @_animFrame

    @_animFrame = requestAnimationFrame _step

  destroy : ->
    cancelAnimationFrame @_animFrame
    clearInterval @_interval


TIME_CONSTANT = 150

IntertialSwipable = React.createClass {
  displayName : 'IntertialSwipable'

  propTypes :
    onSwiping   : React.PropTypes.func
    onSwiped    : React.PropTypes.func
    itemOffsets : React.PropTypes.array

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
    e.preventDefault()
    @_logicBox.onTouchStart e

  _onTouchMove : (e) ->
    if e.touches.length > 1
      return
    e.preventDefault()
    @_logicBox.onTouchMove e

  _onTouchEnd : (e) ->
    if e.touches.length > 1
      return
    e.preventDefault()
    @_logicBox.onTouchEnd e

  componentWillReceiveProps : (nextProps) ->
    if not _.isEqual(nextProps.itemOffsets, @props.itemOffsets)
      @_logicBox?.destroy()
      @_logicBox = new IntertialSwipeLogicBox {
        itemOffsets   : nextProps.itemOffsets
        onChangeDelta : nextProps.onSwiping
      }

  componentWillUnmount : ->
    @_logicBox?.destroy()
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
      itemOffsets={@state.itemOffsets}
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

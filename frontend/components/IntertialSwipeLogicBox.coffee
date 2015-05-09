_ = require 'lodash'

assert = require '../../shared/tinyassert'

TIME_CONSTANT = 150

# TODO: Snap to nearest.
class IntertialSwipeLogicBox
  constructor : ({ @itemOffsets, @onChangeDelta, @onFinish }) ->
    assert @itemOffsets

    _.extend @, {
      trueDelta           : 0
      visibleDelta        : 0
      lastX               : null
      lastTrackedTime     : Date.now()
      lastTrackedDelta    : 0
      lastTrackedVelocity : 0
    }

  onTouchStart : (e) =>
    if @_animFrame?
      cancelAnimationFrame @_animFrame

    @_set {
      lastX               : e.touches[0].clientX
      lastTrackedTime     : Date.now()
      lastTrackedDelta    : @visibleDelta
      lastTrackedVelocity : 0
    }

    @_interval = setInterval @_trackVelocity, 50

  onTouchMove : (e) =>
    trueDelta = @trueDelta - (e.changedTouches[0].clientX - @lastX)
    visibleDelta = @_computeResistance trueDelta

    @_set {
      trueDelta
      visibleDelta
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

  _set : (fields) =>
    if fields.visibleDelta? and fields.visibleDelta != @visibleDelta
      @onChangeDelta?(fields.visibleDelta)

    _.extend @, fields

  _trackVelocity : =>
    now = Date.now()
    elapsed = now - @lastTrackedTime

    v = 1000 * (@visibleDelta - @lastTrackedDelta) / (1 + elapsed)

    @_set {
      lastTrackedTime     : now
      lastTrackedDelta    : @visibleDelta
      lastTrackedVelocity : 0.8 * v + 0.2 * @lastTrackedVelocity
    }

  _computeResistance : (trueDelta) =>
    if trueDelta > _.last(@itemOffsets)
      overflow = trueDelta - _.last(@itemOffsets)
      return _.last(@itemOffsets) + Math.sqrt(overflow) * 4
    else if trueDelta < 0
      return -Math.sqrt(Math.abs(trueDelta)) * 4
    else
      return trueDelta

  _uncomputeResistance : (visibleDelta) =>
    if visibleDelta > _.last(@itemOffsets)
      overflow = visibleDelta - _.last(@itemOffsets)
      return _.last(@itemOffsets) + Math.pow(overflow / 4, 2)
    else if visibleDelta < 0
      return -Math.pow(Math.abs(visibleDelta) / 4, 2)
    else
      return visibleDelta

  _isVisibleDeltaInRange : =>
    return 0 < @visibleDelta < _.last(@itemOffsets)

  _autoScrollToDerivedDelta : ->
    if not @_isVisibleDeltaInRange()
      @_bounceBackIfNecessary()
      return

    amplitude = 0.3 * @lastTrackedVelocity
    target    = @trueDelta + amplitude

    @_animate {
      amplitude

      onStep : (stepDelta) =>
        trueDelta = target + stepDelta
        visibleDelta = @_computeResistance trueDelta

        if Math.abs(visibleDelta - @visibleDelta) < 5 and not @_isVisibleDeltaInRange()
          @_set { trueDelta, visibleDelta }
          delete @_animFrame
          @_bounceBackIfNecessary()
          return false
        else
          @_set { trueDelta, visibleDelta }
    }

  _bounceBackIfNecessary : ->
    if @visibleDelta < 0
      amplitude = -@visibleDelta
      target = 0
    else if @visibleDelta > _.last(@itemOffsets)
      amplitude = -(@visibleDelta - _.last(@itemOffsets))
      target = _.last @itemOffsets
    else
      @onFinish?()
      return

    @_animate {
      amplitude

      onStep : (stepDelta) =>
        visibleDelta = target + stepDelta
        trueDelta = @_uncomputeResistance visibleDelta
        @_set { trueDelta, visibleDelta }

      onFinish : =>
        @_set {
          trueDelta    : target
          visibleDelta : target
        }
        @onFinish?()
    }

  _animate : ({ amplitude, onStep, onFinish }) ->
    startTime = Date.now()
    _step = =>
      elapsed = Date.now() - startTime
      stepDelta = -amplitude * Math.exp(-elapsed / TIME_CONSTANT)
      if stepDelta < -1 or stepDelta > 1
        # Must literally return false. Note that this will NOT call onFinish.
        if onStep(stepDelta) != false
          @_animFrame = requestAnimationFrame _step
      else
        onFinish?()
        delete @_animFrame

    @_animFrame = requestAnimationFrame _step

  destroy : ->
    cancelAnimationFrame @_animFrame
    clearInterval @_interval

module.exports = IntertialSwipeLogicBox

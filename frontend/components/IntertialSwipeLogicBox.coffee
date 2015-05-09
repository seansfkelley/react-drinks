_ = require 'lodash'

assert = require '../../shared/tinyassert'

TIME_CONSTANT = 150

class IntertialSwipeLogicBox
  constructor : ({ @itemOffsets, @initialDelta, @onChangeDelta, @onFinish }) ->
    assert @itemOffsets

    @_set {
      trueDelta           : @initialDelta ? 0
      visibleDelta        : @initialDelta ? 0
      lastX               : null
      lastTrackedTime     : null
      lastTrackedDelta    : null
      lastTrackedVelocity : null
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
    @_set { lastX : null }

    @_autoScrollToDerivedDelta()

  # TODO: We probably actually want to animate this.
  setDeltaInstantly : (delta) =>
    assert @_isInRange(delta)

    @_set {
      visibleDelta : delta
      trueDelta    : delta
    }

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

  _isInRange: (value) =>
    return 0 <= value <= _.last(@itemOffsets)

  _snapToNearestOffset : (value) ->
    i = _.sortedIndex @itemOffsets, value
    if i == 0
      return _.first @itemOffsets
    else if i == @itemOffsets.length
      return _.last @itemOffsets
    else if Math.abs(value - @itemOffsets[i - 1]) < Math.abs(value - @itemOffsets[i])
      return @itemOffsets[i - 1]
    else
      return @itemOffsets[i]

  _autoScrollToDerivedDelta : ->
    if not @_isInRange(@visibleDelta)
      @_bounceBackIfNecessary()
      return

    amplitude = 0.3 * @lastTrackedVelocity
    target    = @trueDelta + amplitude

    if @_isInRange(target)
      target = @_snapToNearestOffset target
      amplitude = target - @trueDelta

    @_animate {
      amplitude

      onStep : (stepDelta) =>
        trueDelta = target + stepDelta
        visibleDelta = @_computeResistance trueDelta

        if Math.abs(visibleDelta - @visibleDelta) < 5 and not @_isInRange(@visibleDelta)
          @_set { trueDelta, visibleDelta }
          delete @_animFrame
          @_bounceBackIfNecessary()
          return false
        else
          @_set { trueDelta, visibleDelta }

      onFinish : =>
        @_set {
          trueDelta    : target
          visibleDelta : target
        }
        @onFinish?()
    }

  _bounceBackIfNecessary : ->
    if @visibleDelta < 0
      target = 0
    else if @visibleDelta > _.last(@itemOffsets)
      target = _.last @itemOffsets
    else
      target = @visibleDelta

    @_animate {
      amplitude : target - @visibleDelta

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

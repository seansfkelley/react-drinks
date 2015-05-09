_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

assert = require '../../shared/tinyassert'

TIME_CONSTANT = 150

class IntertialSwipeLogicBox
  constructor : ({ @itemOffsets, @onChangeDelta }) ->
    assert @itemOffsets
    assert @onChangeDelta

    _.extend @, {
      trueDelta           : 0
      visibleDelta        : 0
      lastX               : null
      lastTrackedTime     : Date.now()
      lastTrackedDelta    : 0
      lastTrackedVelocity : 0
    }

  _set : (fields) =>
    if fields.visibleDelta? and fields.visibleDelta != @visibleDelta
      @onChangeDelta fields.visibleDelta

    _.extend @, fields

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

    startTime = Date.now()
    _step = =>
      elapsed = Date.now() - startTime
      stepDelta = -amplitude * Math.exp(-elapsed / TIME_CONSTANT)
      if stepDelta < -1 or stepDelta > 1
        trueDelta = target + stepDelta
        visibleDelta = @_computeResistance trueDelta
        if Math.abs(visibleDelta - @visibleDelta) < 5 and not @_isVisibleDeltaInRange()
          @_bounceBackIfNecessary()
          delete @_animFrame
        else
          @_animFrame = requestAnimationFrame _step

        @_set { trueDelta, visibleDelta }
      else
        delete @_animFrame

    @_animFrame = requestAnimationFrame _step

  _bounceBackIfNecessary : ->
    if @visibleDelta < 0
      amplitude = -@visibleDelta
      target = 0
    else if @visibleDelta > _.last(@itemOffsets)
      amplitude = -(@visibleDelta - _.last(@itemOffsets))
      target = _.last @itemOffsets
    else
      return

    startTime = Date.now()
    _step = =>
      elapsed = Date.now() - startTime
      stepDelta = -amplitude * Math.exp(-elapsed / TIME_CONSTANT)
      if stepDelta < -1 or stepDelta > 1
        visibleDelta = target + stepDelta
        trueDelta = @_uncomputeResistance visibleDelta
        @_set { trueDelta, visibleDelta }
        @_animFrame = requestAnimationFrame _step
      else
        @_set {
          trueDelta    : target
          visibleDelta : target
        }
        delete @_animFrame

    @_animFrame = requestAnimationFrame _step

  destroy : ->
    cancelAnimationFrame @_animFrame
    clearInterval @_interval


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

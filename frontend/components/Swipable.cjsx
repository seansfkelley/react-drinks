_              = require 'lodash'
React          = require 'react/addons'
classnames     = require 'classnames'
ReactSwipeable = require 'react-swipeable'

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
      isSwiping   : false
    }

  render : ->
    offset = @state.delta - @state.itemOffsets[@state.index] + (@state.wrapperWidth - @state.itemWidths[@state.index]) / 2

    <ReactSwipeable
      onSwipingLeft={@_onSwipingLeft}
      onSwipingRight={@_onSwipingRight}
      onSwiped={@_onSwiped}
      className={classnames 'viewport-container', @props.className}
    >
      <div
        onTouchTap={@_onTouchTap}
        className='sliding-container'
        ref='slidingContainer'
        style={{
          WebkitTransition : if not @state.isSwiping then '-webkit-transform 0.2s'
          WebkitTransform  : "translateX(#{offset}px) translateZ(0)" # Hardware acceleration.
          transition       : if not @state.isSwiping then 'transform 0.2s'
          transform        : "translateX(#{offset}px)"
        }}
      >
        {@props.children}
      </div>
    </ReactSwipeable>

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

  _addResistance : (delta) ->
    clampedDelta = Math.min Math.abs(delta), 500
    return delta * (2 - Math.sqrt(clampedDelta / 500)) / 3

  _onTouchTap : (e) ->
    target = e.target
    slidingContainer = React.findDOMNode @refs.slidingContainer
    while target.parentNode != slidingContainer
      target = target.parentNode
    @_finishSwipe _.indexOf(slidingContainer.children, target)

  _onSwipingLeft : (e, delta) ->
    if @state.index == React.Children.count(@props.children) - 1
      delta = @_addResistance delta
    @_startSwipe -delta

  _onSwipingRight : (e, delta) ->
    if @state.index == 0
      delta = @_addResistance delta
    @_startSwipe delta

  _startSwipe : (delta) ->
    @setState {
      delta
      isSwiping : true
    }

  _onSwiped : (e, x, y, isFlick) ->
    offsetOffsets = _.chain()
      .range(@state.itemOffsets.length)
      .map (i) => @state.itemOffsets[i] - @state.itemWidths[i] / 2
      .value()
    currentOffset = @state.itemOffsets[@state.index] - @state.delta
    if isFlick
      # How many pixels of momentum is a flick worth?
      currentOffset -= (if @state.delta < 0 then -1 else 1) * 100
    # Erm, why is this -1?
    currentIndex  = _.sortedIndex(offsetOffsets, currentOffset) - 1
    if currentIndex == -1
      currentIndex = 0
    @_finishSwipe currentIndex

  _finishSwipe : (index) ->
    @setState {
      index
      delta     : 0
      isSwiping : false
    }
    @props.onSlideChange index
}

module.exports = Swipable

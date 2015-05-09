_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

IntertialSwipeLogicBox = require './IntertialSwipeLogicBox'

IntertialSwipable = React.createClass {
  displayName : 'IntertialSwipable'

  propTypes :
    onSwiping   : React.PropTypes.func
    onSwiped    : React.PropTypes.func
    itemOffsets : React.PropTypes.array.isRequired

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
        onFinish      : nextProps.onSwiped
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
          WebkitTransform : "translateX(#{-@state.delta}px) translateZ(0)" # Hardware acceleration.
          transform       : "translateX(#{-@state.delta}px)"
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

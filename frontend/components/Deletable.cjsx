_          = require 'lodash'
React      = require 'react'
Draggable  = require 'react-draggable'
classnames = require 'classnames'

DELETABLE_WIDTH = 80

Deletable = React.createClass {
  displayName : 'Deletable'

  propTypes :
    onDelete : React.PropTypes.func.isRequired
    children : React.PropTypes.element.isRequired

  getInitialState : ->
    return {
      initialX       : 0
      deltaX         : 0
      checkFirstMove : true
      ignoreDrag     : false
    }

  render : ->
    renderableProps = _.omit @props, 'onDelete'
    left = DELETABLE_WIDTH - Math.abs(@state.left)
    <Draggable
      axis='x'
      bounds={{ left : -DELETABLE_WIDTH, right : 0 }}
      onStart={@_onDragStart}
      onDrag={@_onDrag}
      onStop={@_onDragEnd}
      ref='draggable'
    >
      <div className={classnames 'deletable', @props.className}>
        {@props.children}
        <div
          className='delete-button'
          style={{ width : Math.abs(@state.deltaX), right : @state.deltaX }}
          onTouchTap={@_onDelete}
        >
          <span className='text' style={{ width : DELETABLE_WIDTH }}>Delete</span>
        </div>
      </div>
    </Draggable>

  _onDelete : (e) ->
    e.stopPropagation()
    @props.onDelete()

  _onDragStart : (e, { position }) ->
    # Do NOT reset deltaX -- it may be dragged open already.
    @setState { initialX : position.left, checkFirstMove : true, ignoreDrag : false }

  _onDrag : (event, { deltaX, deltaY }) ->
    if @state.ignoreDrag
      return false
    else if @state.checkFirstMove and Math.abs(deltaY) > Math.abs(deltaX)
      @setState { ignoreDrag : true }
      return false
    else
      @setState { deltaX : Math.min(Math.max(@state.deltaX + deltaX, -DELETABLE_WIDTH), 0) }
    @setState { checkFirstMove : false }

  _onDragEnd : (event, { position }) ->
    if @state.deltaX < -DELETABLE_WIDTH / 2
      @refs.draggable.setState { clientX :  -DELETABLE_WIDTH }
      @setState { deltaX : -DELETABLE_WIDTH }
    else
      @refs.draggable.setState { clientX : 0 }
      @setState { deltaX : 0 }
}

module.exports = Deletable

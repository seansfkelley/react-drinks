# @cjsx React.DOM

_          = require 'lodash'
React      = require 'react'
Draggable  = require 'react-draggable'
classnames = require 'classnames'

DELETABLE_WIDTH = 80

Deletable = React.createClass {
  displayName : 'Deletable'

  propTypes :
    onDelete : React.PropTypes.func.isRequired

  getInitialState : ->
    return {
      left : 0
    }

  render : ->
    renderableProps = _.omit @props, 'onDelete'
    left = DELETABLE_WIDTH - Math.abs(@state.left)
    <Draggable axis='x' onDrag={@_clampDrag} onStop={@_onDragEnd} ref='draggable'>
      <div className={classnames 'deletable', @props.className}>
        {@props.children}
        <div
          className='delete-button'
          style={{ width : Math.abs(@state.left), right : @state.left }}
          onTouchTap={@_onDelete}
        >
          <span className='text' style={{ width : DELETABLE_WIDTH }}>Delete</span>
        </div>
      </div>
    </Draggable>

  _onDelete : (e) ->
    e.stopPropagation()
    @props.onDelete()

  _clampDrag : (event, { position }) ->
    if position.left > 0
      @refs.draggable.setState { clientX : 0 }
      @setState { left : 0 }
    else if position.left < -DELETABLE_WIDTH
      @refs.draggable.setState { clientX : -DELETABLE_WIDTH }
      @setState { left : -DELETABLE_WIDTH }
    else
      @setState { left : position.left }

  _onDragEnd : (event, { position }) ->
    if position.left < -DELETABLE_WIDTH / 2
      @refs.draggable.setState { clientX : -DELETABLE_WIDTH }
      @setState { left : -DELETABLE_WIDTH }
    else
      @refs.draggable.setState { clientX : 0 }
      @setState { left : 0 }
}

module.exports = Deletable

# @cjsx React.DOM

React = require 'react'

utils = require '../utils'

KeyCode = {
  BACKSPACE  : 8
  ENTER      : 13
  SPACE      : 32
  ARROW_KEYS : [ 37, 38, 39, 40 ]
}

BORING_INPUT_PROPS = {
  type           : 'text'
  autoCorrect    : 'off'
  autoCapitalize : 'off'
  autoComplete   : 'off'
  spellCheck     : 'false'
}

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

  propTypes : {}

  getInitialState : ->
    return {
      measure         : ''
      unit            : ''
      display         : ''
      skipOnNextSpace : true
    }

  render : ->
    <div className='editable-ingredient2' onKeyUp={@_maybeRefocus}>
      <input
        className='measure'
        placeholder='#'
        value={@state.measure}
        onChange={@_onMeasureChange}
        onKeyDown={@_onMeasureKeyDown}
        {...BORING_INPUT_PROPS}
        ref='measure'
      />
      <input
        className='unit'
        placeholder='unit'
        value={@state.unit}
        onChange={@_onUnitChange}
        onKeyDown={@_onUnitKeyDown}
        {...BORING_INPUT_PROPS}
        ref='unit'
      />
      <input
        className='display'
        placeholder='ingredient'
        onChange={@_onDisplayChange}
        onKeyDown={@_onDisplayKeyDown}
        {...BORING_INPUT_PROPS}
        ref='display'
      />
    </div>

  _maybeRefocus : (e) ->
    if @_refToFocus?
      @_refToFocus.getDOMNode().focus()
      @_refToFocus = null

  _onMeasureKeyDown : (e) ->
    if /[a-zA-Z]/.test(String.fromCharCode(e.keyCode)) or e.keyCode == KeyCode.ENTER
      @refs.unit.getDOMNode().focus()
      @setState { measure : @state.measure.trim() }
    else if @state.skipOnNextSpace and e.keyCode == KeyCode.SPACE
      @_refToFocus = @refs.unit
      @setState {
        measure         : @state.measure.trim()
        skipOnNextSpace : false
      }
    else if not @state.skipOnNextSpace and e.keyCode not in KeyCode.ARROW_KEYS
      @setState { skipOnNextSpace : true }

  _onUnitKeyDown : (e) ->
    if e.keyCode == KeyCode.ENTER or e.keyCode == KeyCode.SPACE
      @_refToFocus = @refs.display
      @setState { unit : @state.unit.trim() }
    else if e.keyCode == KeyCode.BACKSPACE and e.target.value == ''
      @_refToFocus = @refs.measure

  _onDisplayKeyDown : (e) ->
    if e.keyCode == KeyCode.BACKSPACE and e.target.value == ''
      @_refToFocus = @refs.unit

  _onMeasureChange : (e) ->
    measure = utils.fractionify e.target.value
    if not @state.skipOnNextSpace
      measure = measure.trim()
    @setState { measure }

  _onUnitChange : (e) ->
    @setState { unit : e.target.value.trim() }

  _onDisplayChange : ->

}

module.exports = EditableIngredient

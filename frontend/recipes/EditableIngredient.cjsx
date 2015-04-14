# @cjsx React.DOM

_          = require 'lodash'
React      = require 'react'
Select     = require 'react-select'
classnames = require 'classnames'

FluxMixin = require '../mixins/FluxMixin'

IngredientGuesser = require '../ingredients/IngredientGuesser'

utils               = require '../utils'
{ IngredientStore } = require '../stores'

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

NO_INGREDIENT_SENTINEL = -1

TagGuesser = React.createClass {
  displayName : 'TagGuesser'

  propTypes :
    forString : React.PropTypes.string.isRequired

  mixins : [
    FluxMixin IngredientStore, 'alphabeticalIngredients'
  ]

  getInitialState : ->
    return {
      isManual : false
    }

  render : ->
    if @state.isManual
      options = _.map IngredientStore.allAlphabeticalIngredients, (i) ->
        return { value : i.tag, label : i.display }

      options.push { value : NO_INGREDIENT_SENTINEL, label : '(none)' }

      guessNode =
        <Select
          className='guess'
          placeholder='Ingredient...'
          clearable=false
          options={options}
          filterOption={@_filterOption}
          autoload=false
          inputProps={BORING_INPUT_PROPS}
        />
    else
      ingredientGuess = new IngredientGuesser(IngredientStore.allAlphabeticalIngredients).guess @props.forString

      if ingredientGuess?
        guessString = ingredientGuess.display
        isUnknown   = false
      else
        guessString = '(none)'
        isUnknown   = true

      guessNode = <div className={classnames 'guess', { 'is-unknown' : isUnknown }}>{guessString}</div>

    <div className={classnames 'tag-guesser', { 'is-manual' : @state.isManual }}>
      <div className='description small-text'>Matched As</div>
      {guessNode}
      {if not @state.isManual
        <div className='change-button-container'>
          <div className='change-button small-text' onTouchTap={@_changeGuess}>Change</div>
        </div>
      }
    </div>

  _changeGuess : ->
    @setState { isManual : true }

  _filterOption : (option, searchString) ->
    if option.value == NO_INGREDIENT_SENTINEL
      return true
    else
      searchString = searchString.toLowerCase()
      # Should expose this search as a utility method on ingredients to ensure consistent behavior.
      ingredient = IngredientStore.ingredientsByTag[option.value]
      return _.any ingredient.searchable, (term) ->  term.indexOf(searchString) != -1

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
    <div className='editable-ingredient'>
      <div className='input-fields' onKeyUp={@_maybeRefocus}>
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
          value={@state.display}
          onChange={@_onDisplayChange}
          onKeyDown={@_onDisplayKeyDown}
          {...BORING_INPUT_PROPS}
          ref='display'
        />
      </div>
      <TagGuesser key='guesser' forString={@state.display}/>
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

  _onDisplayChange : (e) ->
    @setState { display : e.target.value }

}

module.exports = EditableIngredient

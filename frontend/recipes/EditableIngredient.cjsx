# @cjsx React.DOM

_             = require 'lodash'
React         = require 'react'
{ Typeahead } = require 'react-typeahead'
classnames    = require 'classnames'

FluxMixin = require '../mixins/FluxMixin'

utils               = require '../utils'
stylingConstants    = require '../stylingConstants'
{ IngredientStore } = require '../stores'

IngredientGuesser = require '../ingredients/IngredientGuesser'

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

NO_INGREDIENT_SENTINEL = '__n/a__'

_containsActiveElement = (container) ->
  e = document.activeElement
  while e?
    if e == container
      return true
    e = e.parentNode
  return false

TagGuesser = React.createClass {
  displayName : 'TagGuesser'

  propTypes :
    guessString : React.PropTypes.string.isRequired

  mixins : [
    FluxMixin IngredientStore, 'alphabeticalIngredients'
  ]

  getInitialState : ->
    return {
      isManual : false
      choice   : null
      guess    : @_getGuessFor @props.guessString
    }

  render : ->
    if @state.isManual
      options = _.map IngredientStore.allAlphabeticalIngredients, (i) ->
        return { value : i.tag, label : i.display }

      options.push { value : NO_INGREDIENT_SENTINEL, label : '(none)' }

      guessNode =
        <Typeahead
          className='guess'
          options={options}
          placeholder='Ingredient...'
          onOptionSelected={@_selectIngredient}
          filterOption={@_filterOption}
          displayOption='label'
          defaultValue={@state.guess?.display}
          inputProps={BORING_INPUT_PROPS}
          ref='select'
        />
    else
      if @state.guess?
        guessString = @state.guess.display
        isUnknown   = false
      else
        guessString = '(none)'
        isUnknown   = true

      guessNode =
        <div className={classnames 'guess', { 'is-unknown' : isUnknown }} onTouchTap={@_switchToManual}>
          {guessString}
        </div>

    <div className={classnames 'tag-guesser', { 'is-manual' : @state.isManual }}>
      <div className='description small-text'>Matched As</div>
      {guessNode}
      {if not @state.isManual
        <div className='change-button-container'>
          <div className='change-button small-text' onTouchTap={@_switchToManual}>Change</div>
        </div>}
    </div>

  _switchToManual : ->
    @setState {
      isManual : true
      guess    : null
    }

  _selectIngredient : (option) ->
    @setState { choice : option.value }

  _filterOption : (searchString, option) ->
    if option.value == NO_INGREDIENT_SENTINEL
      return true
    else
      searchString = searchString.toLowerCase()
      # Should expose this search as a utility method on ingredients to ensure consistent behavior.
      ingredient = IngredientStore.ingredientsByTag[option.value]
      return _.any ingredient.searchable, (term) ->  term.indexOf(searchString) != -1

  _getGuessFor : (string) ->
    return new IngredientGuesser(IngredientStore.allAlphabeticalIngredients).guess string

  revertToGuessingIfAppropriate : ->
    if @state.isManual and not @state.choice?
      @setState {
        isManual : false
        choice   : null
        guess    : @_getGuessFor @props.guessString
      }

  getTag : ->
    if @state.isManual
      return @state.choice
    else
      return @state.guess?.tag

  componentWillReceiveProps : (nextProps) ->
    @setState { guess : @_getGuessFor(nextProps.guessString) }
}

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

  propTypes :
    shouldGrabFocus : React.PropTypes.bool

  getInitialState : ->
    return {
      measure         : ''
      unit            : ''
      display         : ''
      skipOnNextSpace : true
      isExpanded      : false
      showOverflow    : false
    }

  render : ->
    <div
      className={classnames 'editable-ingredient', { 'is-expanded' : @state.isExpanded, 'show-overflow' : @state.showOverflow }}
      onBlur={@_updateFocus}
      onFocus={@_updateFocus}
    >
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
      <TagGuesser key='guesser' guessString={@state.display} ref='guesser'/>
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

  _updateFocus : ->
    if _containsActiveElement @getDOMNode()
      @setState {
        isExpanded : true
      }
      _.delay (=>
        @setState { showOverflow : true  }
      ), stylingConstants.TRANSITION_DURATION
      if @_isFocusingOnAnyInput()
        @refs.guesser.revertToGuessingIfAppropriate()
    else
      @setState {
        isExpanded   : false
        showOverflow : false
      }

  _isFocusingOnAnyInput : ->
    for r in [ 'measure', 'unit', 'display' ]
      if @refs[r].getDOMNode() == document.activeElement
        return true
    return false

  getIngredient : ->
    return {
      measure     : utils.defractionify @state.measure
      unit        : @state.unit
      description : @state.display
      tag         : @refs.guesser.getTag()
    }

  componentDidMount : ->
    # Something about making this deferred like this fixes an issue where clicking on a
    # typeahead option doesn't actually apply the option the first time.
    @_updateFocus = _.debounce @_updateFocus, 0
    if @props.shouldGrabFocus
      @refs.measure.getDOMNode().focus()
}

module.exports = EditableIngredient

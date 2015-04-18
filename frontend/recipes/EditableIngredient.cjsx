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

# iOS standalone does not fire touch events on input elements, yet regular iOS Safari does. What the fuck.
# Apparently this is a long-standing issue (see comments further down, where this is used). I have an insane
# workaround where I re-fire events, but it should be used judiciously because it's fragile and shitty.
IS_BUGGY_IOS_STANDALONE = !!window.navigator.standalone

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
      className={classnames 'editable-ingredient', {
        'is-expanded'            : @state.isExpanded
        'show-overflow'          : @state.showOverflow
        'prevent-pointer-events' : @state.preventPointerEvents
      }}
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
          onTouchTap={@_generateFocuser('measure')}
          {...BORING_INPUT_PROPS}
          ref='measure'
        />
        <input
          className='unit'
          placeholder='unit'
          value={@state.unit}
          onChange={@_onUnitChange}
          onKeyDown={@_onUnitKeyDown}
          onTouchTap={@_generateFocuser('unit')}
          {...BORING_INPUT_PROPS}
          ref='unit'
        />
        <input
          className='display'
          placeholder='ingredient'
          value={@state.display}
          onChange={@_onDisplayChange}
          onKeyDown={@_onDisplayKeyDown}
          onTouchTap={@_generateFocuser('display')}
          {...BORING_INPUT_PROPS}
          ref='display'
        />
        {if IS_BUGGY_IOS_STANDALONE
          <div className='ios-standalone-grab-target' ref='grabTarget'/>}
      </div>
      <TagGuesser key='guesser' guessString={@state.display} ref='guesser'/>
    </div>

  _generateFocuser : (ref) ->
    return =>
      @refs[ref].getDOMNode().focus()

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
        if @state.isExpanded
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
    if IS_BUGGY_IOS_STANDALONE
      forwardTouchEvents @refs.grabTarget.getDOMNode()

    # Something about making this deferred like this fixes an issue where clicking on a
    # typeahead option doesn't actually apply the option the first time.
    @_updateFocus = _.debounce @_updateFocus, 0
    if @props.shouldGrabFocus
      @refs.measure.getDOMNode().focus()
      # This is gross, but it prevents the 300ms click bullshit from selecting
      # whatever field ends up under your finger when you hit the button.
      @setState { preventPointerEvents : true }
      _.delay (=>
        @setState { preventPointerEvents : false }
      ), 300
}

forwardTouchEvents = (node) ->
  for type in [ 'touchstart', 'touchmove', 'touchend' ]
    node['on' + type] = (e) ->
      e.preventDefault()
      e.stopPropagation()

      { clientX, clientY } = e.touches[0] ? e.changedTouches[0]
      node.style.display = 'none'
      actualTarget = document.elementFromPoint clientX, clientY
      node.style.display = 'block'

      actualTarget?.dispatchEvent cloneEvent(e)


cloneEvent = (e) ->
  newEvent = document.createEvent 'TouchEvent'
  # Inspired by https://gist.github.com/sstephenson/448808 and some tweaking of argument ordering with trial and error.
  # iOS version.
  newEvent.initTouchEvent(
    e.type
    e.bubbles, e.cancelable
    e.view
    e.detail
    0, 0, 0, 0
    e.ctrlKey, e.altKey, e.shiftKey, e.metaKey
    e.touches, e.targetTouches, e.changedTouches
    1, 0
  )
  # Chrome version, for reference/testing.
  # newEvent.initTouchEvent(
  #   e.touches, e.targetTouches, e.changedTouches
  #   e.type
  #   e.view
  #   e.bubbles, e.cancelable
  #   e.detail
  #   0, 0, 0, 0
  #   e.ctrlKey, e.altKey, e.shiftKey, e.metaKey
  # )
  return newEvent


module.exports = EditableIngredient

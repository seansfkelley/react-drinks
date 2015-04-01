# @cjsx React.DOM

_      = require 'lodash'
React  = require 'react'
Select = require 'react-select'

IconButton = require './IconButton'

stylingConstants = require '../stylingConstants'

utils               = require '../utils'
{ IngredientStore } = require '../stores'

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

  propTypes :
    saveIngredient : React.PropTypes.func.isRequired

  getInitialState : ->
    return {
      measure          : null
      measureCommitted : false
      tag              : null
      tagCommitted     : false
      description      : null
    }

  render : ->
    options = _.map IngredientStore.alphabeticalIngredients, (i) ->
      return {
        value : i.tag
        label : i.display
      }

    classNames = 'tile measure'
    disabled = false
    if @state.measureCommitted
      classNames += ' is-committed'
      disabled = true

    measureNode =
      <div className={classNames} onTouchTap={if disabled then @_skipBackToMeasure}>
        {if disabled
          <IconButton className='image-overlay' iconClass='fa-question'/>}
        <input
          type='text'
          className='input-field'
          value={@state.measure}
          onChange={@_onChangeMeasure}
          placeholder='Amount...'
          ref='measure'
          disabled={disabled}
          autoCorrect='off'
          autoCapitalize='off'
          autoComplete='off'
          spellCheck='false'
        />
        <IconButton className='accept-button' iconClass='fa-chevron-right' onTouchTap={@_commitMeasure}/>
      </div>

    classNames = 'tile ingredient'
    disabled = false
    if @state.tagCommitted
      classNames += ' is-committed'
      disabled = true
    else if not @state.measureCommitted
      classNames += ' is-hidden'
      disabled = true

    tagNode =
      <div className={classNames} onTouchTap={if disabled then @_skipBackToTag}>
        {if disabled
          <IconButton className='image-overlay' iconClass='fa-question'/>}
        <Select
          className='input-field'
          value={if @state.tag? then IngredientStore.ingredientsByTag[@state.tag].display}
          placeholder='Ingredient...'
          noResultsText='No ingredients!'
          clearable=false
          options={options}
          filterOption={@_filterOption}
          onChange={@_onIngredientTagSelection}
          autoload=false
          key='select'
          ref='tag'
          disabled={disabled}
        />
        <IconButton className='accept-button' iconClass='fa-chevron-right' onTouchTap={@_commitTag}/>
      </div>

    classNames = 'tile description'
    disabled = false
    if not @state.measureCommitted or not @state.tagCommitted
      classNames += ' is-hidden'
      disabled = true

    descriptionNode =
      <div className={classNames}>
        <input
          type='text'
          className='input-field'
          placeholder='Brand/variety...'
          onChange={@_onChangeDescription}
          disabled={disabled}
          ref='description'
          autoCorrect='off'
          autoCapitalize='off'
          autoComplete='off'
          spellCheck='false'
        />
        <IconButton className='accept-button' iconClass='fa-check' onTouchTap={@_commitDescription}/>
      </div>

    # See _focus for an explanation of the input thing.
    <div className='editable-ingredient'>
      {measureNode}
      {tagNode}
      {descriptionNode}
      <input className='iphone-hack-input' ref='hackInput'/>
    </div>

  # I don't like this function and I would like to make it go away. Unfortunately, this is the only
  # way I could think of to get focus behavior to work sanely. Here's the logic for how this method
  # came about:
  #
  # 1. I would like to slide-in animate inputs as they come in. To do this, I have all of the elements
  #    already rendered off-screen, with just an animated width on the preceding elements necessary to
  #    make them visible.
  # 2. react-select uses a dropdown for the autocomplete. Turning on overflow-x does some something
  #    fucked up that the W3C came up with and causes it to overflow-y and hide the dropdown behind a
  #    scroll bar. What?
  # 3. Next attempt: hide the elements insteadf of just having them off-screen. Not bad.
  # 4. Except now the focus is messed up. If I try to focus elements off-screen, browsers scroll over
  #    to show them and (especially on the iPhone!) this is choppy and terrible. This means we can't
  #    have focus be a function simply of state -- it needs to understand transitions.
  # 5. Solution: drop focus during the transition, then re-apply it when it finishes.
  # 6. Nope, on the iPhone this makes the keyboard pop in and out and is awful. Add this invisible
  #    element to grab focus in the interim, then apply it to the right thing when the animation is done.
  #
  # In summary, I have to write this hacky bullshit because overflow-x doesn't make sense. The only
  # alternative I can think of is to animate in new elements from width zero without ever over-rendering.
  # If you see this comment, then obviously I have no yet been able to figure out how to do this.
  #
  # A nice side effect of the over-render was supposed to be that the iPHone next/previous buttons would
  # work, but neither this nor my proposed alternate will allow that behavior.
  _focus : (ref) ->
    @refs.hackInput.getDOMNode().focus()
    _.delay (=>
      if ref == 'tag'
        @refs[ref].focus()
      else
        @refs[ref].getDOMNode().focus()
    # Add this shitty constant so the iPhone doesn't try to do too much at once
    # and mangle the rendering (try taking it out!).
    ), stylingConstants.TRANSITION_DURATION + 100

  _filterOption : (option, searchString) ->
    searchString = searchString.toLowerCase()
    # Should expose this search as a utility method on ingredients to ensure consistent behavior.
    ingredient = IngredientStore.ingredientsByTag[option.value]
    return _.any ingredient.searchable, (term) ->  term.indexOf(searchString) != -1

  _onChangeMeasure : (e) ->
    @setState { measure : utils.fractionify(e.target.value) }

  _commitMeasure : (e) ->
    e.stopPropagation()
    @setState { measureCommitted : true }
    @_focus 'tag'

  _skipBackToMeasure : ->
    @setState {
      measureCommitted : false
      tagCommitted     : false
    }
    @_focus 'measure'

  _onIngredientTagSelection : (tag) ->
    @setState { tag }

  _commitTag : (e) ->
    e.stopPropagation()
    @setState { tagCommitted : true }
    @_focus 'description'

  _skipBackToTag : ->
    @setState { tagCommitted : false }
    @_focus 'tag'

  _onChangeDescription : (e) ->
    @setState { description : e.target.value }

  _commitDescription : (e) ->
    # Defractionifying is kind of silly, but ensures a saner result to the caller and a nicer UI to the user.
    { measure, unit } = utils.splitMeasure utils.defractionify(@state.measure)
    @props.saveIngredient(_.chain(@state)
      .pick 'tag', 'description'
      .extend { measure, unit }
      .mapValues (v) -> v?.trim() or null # empty2null
      .value()
    )
}

module.exports = EditableIngredient

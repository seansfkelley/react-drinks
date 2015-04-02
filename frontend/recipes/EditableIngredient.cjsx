# @cjsx React.DOM

_          = require 'lodash'
React      = require 'react'
Select     = require 'react-select'
classnames = require 'classnames'

IconButton = require './IconButton'

stylingConstants = require '../stylingConstants'

utils               = require '../utils'
{ IngredientStore } = require '../stores'

Section =
  MEASURE     : 'measure'
  TAG         : 'tag'
  DESCRIPTION : 'description'

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

  propTypes :
    saveIngredient : React.PropTypes.func.isRequired

  getInitialState : ->
    return {
      measure     : null
      tag         : null
      description : null
      current     : Section.MEASURE
    }

  render : ->
    options = _.map IngredientStore.alphabeticalIngredients, (i) ->
      return {
        value : i.tag
        label : i.display
      }

    isCurrent = @state.current == Section.MEASURE
    measureNode =
      <div className={classnames 'tile', 'measure', { 'is-current' : isCurrent }}>
        <input
          type='text'
          className='input-field'
          value={@state.measure}
          onChange={@_onChangeMeasure}
          placeholder='Amount...'
          ref={Section.MEASURE}
          autoCorrect='off'
          autoCapitalize='off'
          autoComplete='off'
          spellCheck='false'
          onTouchTap={@_goToSection(Section.DESCRIPTION)}
          onFocus={@_goToSection(Section.MEASURE)}
        />
        {if isCurrent
          <IconButton className='accept-button' iconClass='fa-chevron-right' onTouchTap={@_goToSection(Section.TAG)}/>
        else
          <IconButton className='image-overlay' iconClass='fa-question'/>}
      </div>

    isCurrent = @state.current == Section.TAG
    tagNode =
      <div className={classnames 'tile', 'tag', { 'is-current' : isCurrent }}>
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
          ref={Section.TAG}
          onTouchTap={@_goToSection(Section.DESCRIPTION)}
          onFocus={@_goToSection(Section.TAG)}
        />
        {if isCurrent
          <IconButton className='accept-button' iconClass='fa-chevron-right' onTouchTap={@_goToSection(Section.DESCRIPTION)}/>
        else
          <IconButton className='image-overlay' iconClass='fa-question'/>}
      </div>

    isCurrent = @state.current == Section.DESCRIPTION
    descriptionNode =
      <div className={classnames 'tile', 'description', { 'is-current' : isCurrent }}>
        <input
          type='text'
          className='input-field'
          placeholder='Brand/variety...'
          onChange={@_onChangeDescription}
          ref={Section.DESCRIPTION}
          autoCorrect='off'
          autoCapitalize='off'
          autoComplete='off'
          spellCheck='false'
          onTouchTap={@_goToSection(Section.DESCRIPTION)}
          onFocus={@_goToSection(Section.DESCRIPTION)}
        />
        {if isCurrent
          <IconButton className='accept-button' iconClass='fa-check' onTouchTap={@_saveRecipe}/>
        else
          <IconButton className='image-overlay' iconClass='fa-question'/>}
      </div>

    <div className='editable-ingredient'>
      {measureNode}
      {tagNode}
      {descriptionNode}
    </div>

  _goToSection : (section) ->
    return =>
      @setState { current : section }

  componentDidUpdate : ->
    if @state.current != Section.TAG
      @refs[Section.TAG].setState {
        isFocused : false
        isOpen    : false
      }
    _.delay (=>
      if @state.current == Section.TAG
        @refs[Section.TAG].focus()
      else
        @refs[@state.current].getDOMNode().focus()
    ), stylingConstants.TRANSITION_DURATION + 100

  _filterOption : (option, searchString) ->
    searchString = searchString.toLowerCase()
    # Should expose this search as a utility method on ingredients to ensure consistent behavior.
    ingredient = IngredientStore.ingredientsByTag[option.value]
    return _.any ingredient.searchable, (term) ->  term.indexOf(searchString) != -1

  _onChangeMeasure : (e) ->
    @setState { measure : utils.fractionify(e.target.value) }

  _onIngredientTagSelection : (tag) ->
    @setState { tag }

  _onChangeDescription : (e) ->
    @setState { description : e.target.value }

  _saveRecipe : (e) ->
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

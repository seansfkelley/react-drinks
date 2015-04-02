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
          ref='description'
          autoCorrect='off'
          autoCapitalize='off'
          autoComplete='off'
          spellCheck='false'
        />
        <IconButton className='accept-button' iconClass='fa-check' onTouchTap={@_commitDescription}/>
      </div>

    <div className='editable-ingredient'>
      {measureNode}
      {tagNode}
      {descriptionNode}
    </div>

  componentDidUpdate : ->
    _.delay (=>
      if @state.measureCommitted
        if @state.tagCommitted
          @refs.description.getDOMNode().focus()
        else
          @refs.tag.focus()
      else
        @refs.measure.getDOMNode().focus()
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

  _skipBackToMeasure : ->
    @setState {
      measureCommitted : false
      tagCommitted     : false
    }

  _onIngredientTagSelection : (tag) ->
    @setState { tag }

  _commitTag : (e) ->
    e.stopPropagation()
    @setState { tagCommitted : true }

  _skipBackToTag : ->
    @setState { tagCommitted : false }

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

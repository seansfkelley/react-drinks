# @cjsx React.DOM

_      = require 'lodash'
React  = require 'react'
Select = require 'react-select'

IconButton = require './IconButton'

utils               = require '../utils'
{ IngredientStore } = require '../stores'

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

  propTypes :
    saveIngredient : React.PropTypes.func.isRequired

  getInitialState : ->
    return {
      measure          : null
      unit             : null
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

    measureNode =
      <div className={'tile measure' + if @state.measureCommitted then ' is-committed' else ''} onTouchTap={@_skipBackToMeasure}>
        <input
          type='text'
          className='input-field'
          value={@state.measure}
          placeholder={if not @state.measureCommitted then 'Amount' else 'Amt.'}
          onChange={@_onChangeMeasure}
          disabled={@state.measureCommitted}
        />
        <IconButton className='accept-button' iconClass='fa-chevron-right' onTouchTap={@_commitMeasure}/>
      </div>

    tagNode =
      <div className={'tile ingredient' + if @state.tagCommitted then ' is-committed' else ''} onTouchTap={@_skipBackToTag}>
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
          disabled={@state.tagCommitted}
        />
        <IconButton className='accept-button' iconClass='fa-chevron-right' onTouchTap={@_commitTag}/>
      </div>

    descriptionNode =
      <div className='tile description'>
        <input
          type='text'
          className='input-field'
          placeholder='Brand/variety...'
          onChange={@_onChangeDescription}
        />
        <IconButton className='accept-button' iconClass='fa-check' onTouchTap={@_commitDescription}/>
      </div>


    <div className='editable-ingredient'>
      {measureNode}
      {tagNode}
      {descriptionNode}
    </div>

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

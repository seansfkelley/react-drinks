# @cjsx React.DOM

_      = require 'lodash'
React  = require 'react'
Select = require 'react-select'

AppDispatcher     = require '../AppDispatcher'

FixedHeaderFooter = require '../components/FixedHeaderFooter'
TitleBar          = require '../components/TitleBar'
ButtonBar         = require '../components/ButtonBar'

ClassNameMixin = require '../mixins/ClassNameMixin'

utils               = require '../utils'
{ IngredientStore } = require '../stores'

IconButton = React.createClass {
  displayName : 'IconButton'

  propTypes :
    iconClass : React.PropTypes.string

  mixins : [
    ClassNameMixin
  ]

  render : ->
    renderableProps = _.omit @props, 'iconClass'
    <div  {...renderableProps} className={@getClassName 'icon-button'}>
      <i className={'fa ' + @props.iconClass}/>
    </div>
}

EditableTitleBar = React.createClass {
  displayName : 'EditableTitleBar'

  propTypes : {}

  render : ->
    <TitleBar>
      <input type='text' onChange={@_onChange} placeholder='Recipe title...'/>
    </TitleBar>

  _onChange : (e) ->
    console.log e.target.value
}

EditableFooter = React.createClass {
  displayName : 'EditableFooter'

  propTypes : {}

  render : ->
    <ButtonBar>
      <ButtonBar.Button icon='fa-save' label='Save' onTouchTap={@_save}/>
      <ButtonBar.Button icon='fa-times' label='Close' onTouchTap={@_close}/>
    </ButtonBar>

  _save : ->
    console.log 'save'

  _close : ->
    AppDispatcher.dispatch {
      type : 'hide-modal'
    }
}

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
    @props.saveIngredient _.pick(@state, 'measure', 'tag', 'description')

}

DeletableIngredient = React.createClass {
  displayName : 'DeletableIngredient'

  propTypes :
    measure     : React.PropTypes.string
    unit        : React.PropTypes.string
    tag         : React.PropTypes.string
    description : React.PropTypes.string
    delete      : React.PropTypes.func.isRequired

  render : ->
    <div className='deletable-ingredient'>
      <IconButton iconClass='fa-times' onTouchTap={@_delete}/>
      <div className='measure'>
        {@props.measure}
        {' '}
        <span className='unit'>{@props.unit}</span>
      </div>
      <span className='ingredient'>{@props.description ? IngredientStore.ingredientsByTag[@props.tag].display}</span>
    </div>

  _delete : ->
    @props.delete()
}

EditableRecipeView = React.createClass {
  displayName : 'EditableRecipeView'

  propTypes : {}

  getInitialState : ->
    return {
      ingredients       : []
      currentIngredient : @_newIngredientId()
    }

  render : ->
    deletableIngredients = _.map @state.ingredients, (i) =>
      return <DeletableIngredient {...i} delete={@_generateDeleteCallback(i.id)}/>

    if @state.currentIngredient?
      editingIngredient = <EditableIngredient key={@state.currentIngredient} saveIngredient={@_saveIngredient}/>

    <FixedHeaderFooter
      className='default-modal editable-recipe-view'
      header={<EditableTitleBar/>}
      footer={<EditableFooter/>}
    >
      {deletableIngredients}
      {editingIngredient}
    </FixedHeaderFooter>

  _saveIngredient : ({ measure, tag, description }) ->
    description or= null # empty2null
    ingredient = _.extend { tag, description }, utils.splitMeasure measure
    @setState {
      ingredients       : @state.ingredients.concat [
        _.defaults { id : @state.currentIngredient }, ingredient
      ]
      currentIngredient : @_newIngredientId()
    }

  _generateDeleteCallback : (id) ->
    return =>
      @setState {
        ingredients : _.reject @state.ingredients, { id }
      }

  _newIngredientId : ->
    return _.uniqueId 'ingredient-'
}

module.exports = EditableRecipeView

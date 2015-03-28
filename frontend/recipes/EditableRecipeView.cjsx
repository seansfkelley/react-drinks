# @cjsx React.DOM

_      = require 'lodash'
React  = require 'react'

AppDispatcher     = require '../AppDispatcher'

FixedHeaderFooter  = require '../components/FixedHeaderFooter'
TitleBar           = require '../components/TitleBar'
ButtonBar          = require '../components/ButtonBar'
IconButton         = require './IconButton'
EditableIngredient = require './EditableIngredient'

utils               = require '../utils'
{ IngredientStore } = require '../stores'

EditableTitleBar = React.createClass {
  displayName : 'EditableTitleBar'

  propTypes : {}

  render : ->
    <TitleBar>
      <input type='text' placeholder='Recipe title...' ref='input'/>
    </TitleBar>

  getText : ->
    return @refs.input.value
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
        {utils.fractionify @props.measure}
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

  _saveIngredient : (ingredient) ->
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

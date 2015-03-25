# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FixedHeaderFooter = require '../components/FixedHeaderFooter'
TitleBar          = require '../components/TitleBar'
ButtonBar         = require '../components/ButtonBar'

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
    console.log 'close'
}

EditableTextField = React.createClass {
  displayName : 'EditableTextField'

  propTypes :
    onChange : React.PropTypes.func.isRequired

  render : ->
    <div className='editable-text-field'>
      <input type='text' onChange={@_onChange}/>
    </div>

  _onChange : (e) ->
    @props.onChange e.target.value
}

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

  propTypes :
    onRemove : React.PropTypes.func.isRequired

  render : ->
    <div className='editable-ingredient'>
      <div className='remove-button' onTouchTap={@_remove}>
        <i className='fa fa-minus'/>
      </div>
      <EditableTextField/>
      <EditableTextField/>
    </div>

  _remove : ->
    @props.onRemove()
}

EditableRecipeView = React.createClass {
  displayName : 'EditableRecipeView'

  propTypes : {}

  getInitialState : ->
    return {
      ingredients : [ @_newIngredientId() ]
    }

  render : ->
    <FixedHeaderFooter
      className='default-modal editable-recipe-view'
      header={<EditableTitleBar/>}
      footer={<EditableFooter/>}
    >
      {_.map @state.ingredients, (id) =>
        <EditableIngredient key={id} onRemove={@_generateRemoveCallback(id)}/>}
      <button className='add-ingredient-button' onTouchTap={@_addIngredient}>
        Add Ingredient
      </button>
    </FixedHeaderFooter>

  _generateRemoveCallback : (id) ->
    return =>
      @setState {
        ingredients : _.without @state.ingredients, id
      }

  _addIngredient : ->
    @setState {
      ingredients : @state.ingredients.concat [ @_newIngredientId() ]
    }

  _newIngredientId : ->
    return _.uniqueId 'ingredient-'
}

module.exports = EditableRecipeView

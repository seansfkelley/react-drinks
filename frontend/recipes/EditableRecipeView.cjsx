# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

Select = require 'react-select'

FixedHeaderFooter = require '../components/FixedHeaderFooter'
TitleBar          = require '../components/TitleBar'
ButtonBar         = require '../components/ButtonBar'

{ IngredientStore } = require '../stores'

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

EditableIngredient2 = React.createClass {
  displayName : 'EditableIngredient2'

  propTypes : {}

  render : ->
    options = _.map IngredientStore.alphabeticalIngredients, (i) ->
      return {
        value : i.tag
        label : i.display
      }

    <div className='editable-ingredient-2'>
      <Select
        className='tile'
        placeholder='Ingredient...'
        noResultsText='No ingredients!'
        clearable=false
        options={options}
        filterOption={@_filterOption}
        onChange={@_onChange}
        autoload=false
      />
      <div className='tile edit-button'>
        <i className='fa fa-edit'/>
      </div>
      <div className='tile save-button'>
        <i className='fa fa-check'/>
      </div>
    </div>


  _filterOption : (option, searchString) ->
    searchString = searchString.toLowerCase()
    # Should expose this search as a utility method on ingredients to ensure consistent behavior.
    ingredient = IngredientStore.ingredientsByTag[option.value]
    return _.any ingredient.searchable, (term) ->  term.indexOf(searchString) != -1


  _onChange : (value) ->
    console.log value
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
      <EditableIngredient/>
      {_.map @state.ingredients, (id) =>
        <EditableIngredient2 key={id} onRemove={@_generateRemoveCallback(id)}/>}
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

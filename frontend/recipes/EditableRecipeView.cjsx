# @cjsx React.DOM

_      = require 'lodash'
React  = require 'react'
Select = require 'react-select'

AppDispatcher     = require '../AppDispatcher'

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
    AppDispatcher.dispatch {
      type : 'hide-modal'
    }
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

  getInitialState : ->
    return {
      tag            : null
      ingredientText : null
      searchValue    : null
      editingText    : false
    }

  render : ->
    options = _.map IngredientStore.alphabeticalIngredients, (i) ->
      return {
        value : i.tag
        label : i.display
      }

    # It seems that setting value is necessary in order to have the
    # control maintain the selection once we trigger a state change.
    <div className={'editable-ingredient-2' + if @state.editingText then ' is-editing-text' else ''}>
      <Select
        className='tile'
        placeholder='Ingredient...'
        noResultsText='No ingredients!'
        clearable=false
        options={options}
        filterOption={@_filterOption}
        onChange={@_onIngredientTagSelection}
        autoload=false
        key='select-ingredient'
        value={if @state.tag? then IngredientStore.ingredientsByTag[@state.tag].display}
        disabled={@state.editingText}
      />
      {if @state.tag?
        <div className='tile edit-button animate-in' onTouchTap={@_editText}>
          <i className='fa fa-edit'/>
        </div>}
      <div className={'tile save-button' + if not @state.tag? then ' disabled' else ''} onTouchTap={@_onAccept}>
        <i className='fa fa-check'/>
      </div>
      <input type='text' className={'clarifying-text ' + if @state.editingText then 'animate-in' else 'animate-out'} placeholder='More detailed...'/>
    </div>


  _filterOption : (option, searchString) ->
    searchString = searchString.toLowerCase()
    # Should expose this search as a utility method on ingredients to ensure consistent behavior.
    ingredient = IngredientStore.ingredientsByTag[option.value]
    return _.any ingredient.searchable, (term) ->  term.indexOf(searchString) != -1

  _onIngredientTagSelection : (value) ->
    if IngredientStore.ingredientsByTag[value]
      @setState { tag : value }
    else
      @setState { tag : null }

  _editText : ->
    @setState { editingText : true }

  _onAccept : ->
    if @state.editingText
      @setState { editingText : false }
      document.activeElement.blur()
    else
      console.log 'commit it!'

}

EditableIngredient3 = React.createClass {
  displayName : 'EditableIngredient3'

  propTypes : {}

  getInitialState : ->
    return {
      amount          : null
      amountCommitted : false
      tag             : null
      tagCommitted    : false
      description     : null
    }

  render : ->
    options = _.map IngredientStore.alphabeticalIngredients, (i) ->
      return {
        value : i.tag
        label : i.display
      }

    amountNode =
      <div className={'tile amount' + if @state.amountCommitted then ' is-committed' else ''}>
        <input
          type='text'
          className='input-field'
          placeholder={if not @state.amountCommitted then 'Amount' else 'Amt.'}
          disabled={@state.amountCommitted}
          onChange={@_onChangeAmount}/>
        <div className='accept-button' onTouchTap={@_commitAmount}>
          <i className='fa fa-chevron-right'/>
        </div>
      </div>

    tagNode =
      <div className={'tile ingredient' + if @state.tagCommitted then ' is-committed' else ''}>
        <Select
          className='input-field'
          placeholder='Ingredient...'
          noResultsText='No ingredients!'
          clearable=false
          options={options}
          filterOption={@_filterOption}
          onChange={@_onIngredientTagSelection}
          autoload=false
          key='select-ingredient'
          disabled={@state.tagCommitted}
        />
        <div className='accept-button' onTouchTap={@_commitTag}>
          <i className='fa fa-chevron-right'/>
        </div>
      </div>

        # value={if @state.tag? then IngredientStore.ingredientsByTag[@state.tag].display}

    descriptionNode =
      <div className='tile description'>
        <input type='text' className='input-field' placeholder='Description...' onChange={@_onChangeDescription}/>
        <div className='accept-button' onTouchTap={@_commitDescription}>
          <i className='fa fa-check'/>
        </div>
      </div>


    <div className='editable-ingredient-3'>
      {amountNode}
      {tagNode}
      {descriptionNode}
    </div>

  _filterOption : (option, searchString) ->
    searchString = searchString.toLowerCase()
    # Should expose this search as a utility method on ingredients to ensure consistent behavior.
    ingredient = IngredientStore.ingredientsByTag[option.value]
    return _.any ingredient.searchable, (term) ->  term.indexOf(searchString) != -1

  _commitAmount : ->
    @setState { amountCommitted : true }

  _commitTag : ->
    @setState { tagCommitted : true }

  _commitDescription : ->
    console.log 'save ingredient!'

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
        <EditableIngredient3 key={id} onRemove={@_generateRemoveCallback(id)}/>}
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

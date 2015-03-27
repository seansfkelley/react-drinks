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

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

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


    <div className='editable-ingredient'>
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

# @cjsx React.DOM

_      = require 'lodash'
React  = require 'react'
Select = require 'react-select'

AppDispatcher     = require '../AppDispatcher'

FixedHeaderFooter = require '../components/FixedHeaderFooter'
TitleBar          = require '../components/TitleBar'
ButtonBar         = require '../components/ButtonBar'

utils               = require '../utils'
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

  propTypes :
    saveIngredient : React.PropTypes.func.isRequired

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
      <div className={'tile amount' + if @state.amountCommitted then ' is-committed' else ''} onTouchTap={@_skipBackToAmount}>
        <input
          type='text'
          className='input-field'
          value={@state.amount}
          placeholder={if not @state.amountCommitted then 'Amount' else 'Amt.'}
          onChange={@_onChangeAmount}
          disabled={@state.amountCommitted}
        />
        <div className='accept-button' onTouchTap={@_commitAmount}>
          <i className='fa fa-chevron-right'/>
        </div>
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
        <div className='accept-button' onTouchTap={@_commitTag}>
          <i className='fa fa-chevron-right'/>
        </div>
      </div>

    descriptionNode =
      <div className='tile description'>
        <input type='text' className='input-field' placeholder='Brand/variety...' onChange={@_onChangeDescription}/>
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

  _onChangeAmount : (e) ->
     @setState { amount : utils.fractionify(e.target.value) }

  _commitAmount : (e) ->
    e.stopPropagation()
    @setState { amountCommitted : true }

  _skipBackToAmount : ->
    @setState {
      amountCommitted : false
      tagCommitted    : false
    }

  _onIngredientTagSelection : (tag) ->
    @setState { tag }

  _commitTag : (e) ->
    e.stopPropagation()
    @setState { tagCommitted : true }

  _skipBackToTag : ->
    @setState { tagCommitted : false }

  _commitDescription : ->
    @props.saveIngredient _.pick(@state, 'amount', 'tag', 'description')

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
    deletableIngredients = _.map @state.ingredients, ({ amount, tag, description }) ->
      <div>{amount} {tag}</div>

    if @state.currentIngredient?
      editingIngredient = <EditableIngredient key={@state.currentIngredient} saveIngredient={@_saveIngredient}/>

    <FixedHeaderFooter
      className='default-modal editable-recipe-view'
      header={<EditableTitleBar/>}
      footer={<EditableFooter/>}
    >
      {deletableIngredients}
      {editingIngredient}
      <button
        className='add-ingredient-button'
        disabled={@state.currentIngredient?}
        onTouchTap={@_addIngredient}
      >
        Add Ingredient
      </button>
    </FixedHeaderFooter>

  _saveIngredient : (ingredient) ->
    @setState {
      ingredients       : @state.ingredients.concat [ ingredient ]
      currentIngredient : @_newIngredientId()
    }

  _addIngredient : ->
    @setState {
      currentIngredient : @_newIngredientId()
    }

  _newIngredientId : ->
    return _.uniqueId 'ingredient-'
}

module.exports = EditableRecipeView

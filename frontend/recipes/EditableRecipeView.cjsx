# @cjsx React.DOM

_      = require 'lodash'
React  = require 'react'

AppDispatcher     = require '../AppDispatcher'

FixedHeaderFooter  = require '../components/FixedHeaderFooter'
TitleBar           = require '../components/TitleBar'
ButtonBar          = require '../components/ButtonBar'
IconButton         = require './IconButton'
EditableIngredient = require './EditableIngredient'

stylingConstants = require '../stylingConstants'

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

  focus : ->
    @refs.input.getDOMNode().focus()
}

EditableFooter = React.createClass {
  displayName : 'EditableFooter'

  propTypes :
    canSave : React.PropTypes.bool
    save    : React.PropTypes.func.isRequired

  render : ->
    <ButtonBar>
      <ButtonBar.Button icon='fa-save' label='Save' disabled={not @props.canSave} onTouchTap={@_save}/>
      <ButtonBar.Button icon='fa-times' label='Close' onTouchTap={@_close}/>
    </ButtonBar>

  _save : ->
    return if not @props.canSave
    @props.save()

  _close : ->
    AppDispatcher.dispatch {
      type : 'hide-modal'
    }
}

EditableTextArea = React.createClass {
  displayName : 'EditableTextArea'

  propTypes :
    placeholder : React.PropTypes.string

  render : ->
    <textarea
      className='editable-text-area'
      placeholder={@props.placeholder}
      onInput={@_onInput}
      ref='textarea'/>

  getText : ->
    return @refs.textarea.getDOMNode().value

  componentDidMount : ->
    @_sizeToFit()

  # This is kind of crap:
  #   1. Requires a reflow (seems to be the only way to be accurate, though:
  #      https://github.com/andreypopp/react-textarea-autosize/blob/master/index.js)
  #   2. Doesn't use state. Seems bad, but can't prove it.
  _sizeToFit : _.throttle(->
    # +2 is because of the border: avoids a scrollbar.
    node = @getDOMNode()
    node.style.height = 'auto'
    node.style.height = node.scrollHeight + 2
  ), 100

  _onInput : ->
    @_sizeToFit()
}

DeletableIngredient = React.createClass {
  displayName : 'DeletableIngredient'

  # This requires at least one of tag or description. Not sure how to validate that.
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
      <span className='ingredient'>{@props.description ? IngredientStore.ingredientsByTag[@props.tag]?.display}</span>
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
      return <DeletableIngredient {...i} key={i.id} delete={@_generateDeleteCallback(i.id)}/>

    editingIngredient = <EditableIngredient key={@state.currentIngredient} saveIngredient={@_saveIngredient}/>

    header = <EditableTitleBar ref='title'/>
    footer = <EditableFooter canSave=true save={@_saveRecipe}/>

    <FixedHeaderFooter
      className='default-modal editable-recipe-view'
      header={header}
      footer={footer}
    >
      <div className='recipe-description'>
        <div className='recipe-ingredients'>
          {if deletableIngredients.length
            [
              <div className='recipe-section-header' key='deletable-header'>Ingredients</div>
              deletableIngredients
            ]
          }
          <div className='recipe-section-header'>New Ingredient...</div>
          {editingIngredient}
        </div>
        <div className='recipe-instructions'>
          <div className='recipe-section-header'>Instructions</div>
          <EditableTextArea placeholder='Required...' ref='instructions'/>
        </div>
        <div className='recipe-notes'>
          <div className='recipe-section-header'>Notes</div>
          <EditableTextArea placeholder='Optional...' ref='notes'/>
        </div>
      </div>
    </FixedHeaderFooter>

  componentDidMount : ->
    _.delay (=>
      @refs.title.focus()
    ), stylingConstants.TRANSITION_DURATION

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

  _saveRecipe : ->
    console.log 'save recipe'
}

module.exports = EditableRecipeView

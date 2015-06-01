_      = require 'lodash'
React  = require 'react/addons'

{ IngredientStore } = require '../stores'

List              = require '../components/List'
FixedHeaderFooter = require '../components/FixedHeaderFooter'
Deletable         = require '../components/Deletable'

AppDispatcher = require '../AppDispatcher'

MeasuredIngredient = require './MeasuredIngredient'

store = {
  name         : ''
  ingredients  : [
    isEditing : false
    raw       : '1 oz gin'
    display   :
      displayAmount     : '1'
      displayUnit       : 'oz'
      displayIngredient : 'gin'
  ,
    isEditing : true
    raw       : '1/2 oz Lillet'
  ,
    isEditing : false
    raw       : '1/4 oz vodka'
    display   :
      displayAmount     : '1/4'
      displayUnit       : 'oz'
      displayIngredient : 'vodka'
  ]
  instructions : ''
  notes        : ''
}

NavigationHeader = React.createClass {
  displayName : 'NavigationHeader'

  propTypes :
    backTitle : React.PropTypes.string
    goBack    : React.PropTypes.func

  render : ->
    <div className='navigation-header'>
      {if @props.backTitle
        <div className='back-button float-left' onTouchTap={@props.goBack}>
          <i className='fa fa-chevron-left'/>
          <span className='back-button-label'>{@props.backTitle}</span>
        </div>}
      <i className='fa fa-times float-right' onTouchTap={@_closeFlyup}/>
    </div>

  _closeFlyup : ->
    AppDispatcher.dispatch {
      type : 'hide-flyup'
    }
}

EditableNamePage = React.createClass {
  displayName : 'EditableNamePage'

  propTypes :
    next : React.PropTypes.func.isRequired

  render : ->
    <FixedHeaderFooter
      header={<NavigationHeader/>}
      className='editable-recipe-page'
    >
      <div className='name-page'>
        <input
          type='text'
          placeholder='Name...'
          autoCorrect='off'
          autoCapitalize='on'
          autoComplete='off'
          spellCheck='false'
          ref='input'
          defaultValue={store.name}
          onChange={@_onChange}
          onTouchTap={@focus}
        />
        <i className='fa fa-arrow-right' onTouchTap={@props.next}/>
      </div>
    </FixedHeaderFooter>

  focus : ->
    @refs.input.getDOMNode().focus()

  componentDidMount : ->
    @focus()

  _onChange : (e) ->
    store.name = e.target.value
}

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

  propTypes :
    defaultValue : React.PropTypes.string

  render : ->
    <div className='editable-ingredient2'>
      <input
        type='text'
        placeholder='ex: 1 oz gin'
        autoCorrect='on'
        autoCapitalize='off'
        autoComplete='off'
        spellCheck='false'
        ref='input'
        defaultValue={@props.defaultValue}
        onChange={@_onChange}
        onTouchTap={@focus}
      />
      <div className='ingredient-list-header'>A Type Of</div>
      <List className='ingredient-group-list'>
        {for group in _.pluck IngredientStore.groupedIngredients, 'name'
          <List.Item>
            {group}
            <i className='fa fa-chevron-right'/>
          </List.Item>}
      </List>
    </div>

  focus : ->
    @refs.input.getDOMNode().focus()
}

EditableIngredientsPage = React.createClass {
  displayName : 'EditableIngredientsPage'

  propTypes :
    back : React.PropTypes.func.isRequired
    next : React.PropTypes.func.isRequired

  render : ->
    ingredientNodes = _.map store.ingredients, (i) ->
      if i.isEditing
        ingredient = <EditableIngredient defaultValue={i.raw}/>
      else
        ingredient = <MeasuredIngredient {...i.display}/>
      return <Deletable onDelete={console.log.bind(console)}>{ingredient}</Deletable>


    <FixedHeaderFooter
      header={<NavigationHeader backTitle={'"' + store.name + '"'} goBack={@props.back}/>}
      className='editable-recipe-page'
    >
      <div className='ingredients-page'>
        <div className='ingredients-list'>
          {ingredientNodes}
        </div>
        <i className='fa fa-arrow-right' onTouchTap={@props.next}/>
      </div>
    </FixedHeaderFooter>
}


EditableTextPage = React.createClass {
  displayName : 'EditableTextPage'

  propTypes :
    back : React.PropTypes.func.isRequired
    next : React.PropTypes.func.isRequired

  render : ->
    <FixedHeaderFooter
      header={<NavigationHeader backTitle="#{store.ingredients.length} ingredients" goBack={@props.back}/>}
      className='editable-recipe-page'
    >
      <i className='fa fa-arrow-right' onTouchTap={@props.next}/>
    </FixedHeaderFooter>
}

EditableRecipePage =
  NAME        : 'name'
  INGREDIENTS : 'ingredients'
  TEXT        : 'text'

EditableRecipeView = React.createClass {
  displayName : 'EditableRecipeView'

  getInitialState : -> {
    currentPage : EditableRecipePage.NAME
  }

  render : ->
    return switch @state.currentPage
      when EditableRecipePage.NAME
        <EditableNamePage
          next={@_makePageSwitcher(EditableRecipePage.INGREDIENTS)}
        />
      when EditableRecipePage.INGREDIENTS
        <EditableIngredientsPage
          back={@_makePageSwitcher(EditableRecipePage.NAME)}
          next={@_makePageSwitcher(EditableRecipePage.TEXT)}
        />
      when EditableRecipePage.TEXT
        <EditableTextPage
          back={@_makePageSwitcher(EditableRecipePage.INGREDIENTS)}
          next={-> AppDispatcher.dispatch { type : 'hide-flyup' }}
        />

  _makePageSwitcher : (targetPage) ->
    return =>
      @setState { currentPage : targetPage }

}

module.exports = EditableRecipeView

return


Deletable         = require '../components/Deletable'
ButtonBar         = require '../components/ButtonBar'
normalization     = require '../../shared/normalization'

AppDispatcher       = require '../AppDispatcher'
stylingConstants    = require '../stylingConstants'
utils               = require '../utils'
{ IngredientStore } = require '../stores'

EditableTextArea = React.createClass {
  displayName : 'EditableTextArea'

  propTypes :
    placeholder : React.PropTypes.string
    onInput     : React.PropTypes.func

  render : ->
    <textarea
      className='editable-text-area'
      placeholder={@props.placeholder}
      onInput={@_onInput}
      ref='textarea'
    />

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
    @props.onInput?()
}

EditableRecipeView = React.createClass {
  displayName : 'EditableRecipeView'

  propTypes : {}

  getInitialState : ->
    return {
      ingredientIds      : [ @_newIngredientId() ]
      saveable           : false
      focusNewIngredient : false
    }

  render : ->
    editableIngredients = _.map @state.ingredientIds, (id, i) =>
      shouldGrabFocus = i == @state.ingredientIds.length - 1 and @state.focusNewIngredient
      <div className='z-index-wrapper' style={{ zIndex : @state.ingredientIds.length - i }} key={id}>
        <Deletable onDelete={@_generateDeleter(id)}>
          <EditableIngredient shouldGrabFocus={shouldGrabFocus} ref={id}/>
        </Deletable>
      </div>

    header = <EditableTitleBar ref='title' onChange={@_computeSaveable}/>
    footer = <EditableFooter canSave={@state.saveable} save={@_saveRecipe}/>

    <FixedHeaderFooter
      className='default-modal editable-recipe-view'
      header={header}
      footer={footer}
    >
      <div className='recipe-description'>
        <div className='recipe-ingredients'>
          {editableIngredients}
          <div className='new-ingredient-button' onTouchTap={@_newIngredient}>New Ingredient</div>
        </div>
        <div className='recipe-instructions'>
          <div className='recipe-section-header'>Instructions</div>
          <EditableTextArea placeholder='Required...' ref='instructions' onInput={@_computeSaveable}/>
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
    ), stylingConstants.TRANSITION_DURATION + 100

  _newIngredient : ->
    @setState {
      ingredientIds     : @state.ingredientIds.concat [ @_newIngredientId() ]
      focusNewIngredient : true
    }

  _generateDeleter : (id) ->
    return =>
      @setState {
        ingredientIds : _.without @state.ingredientIds, id
      }

  _newIngredientId : ->
    return _.uniqueId 'ingredient-'

  _computeSaveable : ->
    if not @isMounted()
      saveable = false
    else
      saveable = !!(
        @refs.title.getText().length and
        @refs.instructions.getText().length and
        @state.ingredientIds.length
      )
    @setState { saveable }

  _saveRecipe : ->
    # Well, doing two things here certainly seems weird. Time for an Action?
    AppDispatcher.dispatch {
      type : 'save-recipe'
      recipe : @_constructRecipe()
    }
    AppDispatcher.dispatch {
      type : 'hide-modal'
    }

  _constructRecipe : ->
    ingredients = _.map @state.ingredientIds, (id) =>
      { tag, measure, unit, description } = @refs[id].getIngredient()
      return _.pick {
        tag
        displayAmount     : measure
        displayUnit       : unit
        displayIngredient : description
      }, _.identity
    return normalization.normalizeRecipe _.pick({
      ingredients
      name         : @refs.title.getText()
      instructions : @refs.instructions.getText()
      notes        : @refs.notes.getText()
      isCustom     : true
    }, _.identity)
}

module.exports = EditableRecipeView

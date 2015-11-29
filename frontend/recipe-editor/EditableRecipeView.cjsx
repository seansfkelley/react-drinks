# TODO: This GIANT file needs to be broken up once it's clearer what's staying and what's not.

_          = require 'lodash'
React      = require 'react'
classnames = require 'classnames'

ReduxMixin = require '../mixins/ReduxMixin'

normalization = require '../../shared/normalization'
definitions   = require '../../shared/definitions'
assert        = require '../../shared/tinyassert'

List      = require '../components/List'
Deletable = require '../components/Deletable'

store              = require '../store'
EditableRecipePage = require '../EditableRecipePage'

MeasuredIngredient = require '../recipes/MeasuredIngredient'
RecipeView         = require '../recipes/RecipeView'

BASE_TITLES_BY_TAG = {
  'gin'     : 'Gin'
  'vodka'   : 'Vodka'
  'whiskey' : 'Whiskey'
  'rum'     : 'Rum'
  'brandy'  : 'Brandy/Cognac'
  'tequila' : 'Tequila/Mezcal'
  'wine'    : 'Wine/Champagne'
  'liqueur' : 'Liqueur/Other'
}

assert _.intersection(_.keys(BASE_TITLES_BY_TAG), definitions.BASE_LIQUORS).length == definitions.BASE_LIQUORS.length

# TODO: make IconButton class?
# TODO: clicking back into ingredients to edit them
# TODO: show what "type of" it is in the final display
# TODO: "oh you put numbers in" (re: instructions); "I didn't know that it would do the numbers as you go in"
# TODO: clicking on something to edit could be nice
# TODO: "done" button is rather far away

NavigationHeader = React.createClass {
  displayName : 'NavigationHeader'

  propTypes :
    onClose   : React.PropTypes.func.isRequired
    backTitle : React.PropTypes.string
    goBack    : React.PropTypes.func

  render : ->
    <div className='navigation-header fixed-header'>
      {if @props.backTitle
        <div className='back-button float-left' onTouchTap={@props.goBack}>
          <i className='fa fa-chevron-left'/>
          <span className='back-button-label'>{@props.backTitle}</span>
        </div>}
      <i className='fa fa-times float-right' onTouchTap={@_close}/>
    </div>

  _close : ->
    store.dispatch {
      type : 'clear-editable-recipe'
    }

    @props.onClose()
}

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

  propTypes :
    addIngredient              : React.PropTypes.func.isRequired
    ingredientsByTag           : React.PropTypes.object.isRequired
    allAlphabeticalIngredients : React.PropTypes.array.isRequired

  getInitialState : -> {
    tag   : null
    value : ''
  }

  render : ->
    if @state.tag?
      ingredientSelector = <List.Item onTouchTap={@_unsetTag}>
        {@props.ingredientsByTag[@state.tag].display}
        <i className='fa fa-check-circle'/>
      </List.Item>
    else
      ingredientSelector = _.map @props.allAlphabeticalIngredients, ({ display, tag }) =>
        <List.Item onTouchTap={@_tagSetter tag} key="tag-#{tag}">{display}</List.Item>

    <div className='editable-ingredient'>
      <div className='input-line'>
        <input
          type='text'
          placeholder='ex: 1 oz gin'
          autoCorrect='off'
          autoCapitalize='off'
          autoComplete='off'
          spellCheck='false'
          ref='input'
          value={@state.value}
          onChange={@_onChange}
          onTouchTap={@_focus}
        />
        <div
          className={classnames 'done-button', { 'disabled' : not @_isCommittable() }}
          onTouchTap={@_commitIfAllowed}
        >
          Done
        </div>
      </div>
      <div className='ingredient-list-header'>A Type Of</div>
      <List className='ingredient-group-list' onTouchStart={@_dismissKeyboard}>
        {ingredientSelector}
      </List>
    </div>

  _focus : ->
    @refs.input.focus()

  _dismissKeyboard : ->
    @refs.input.blur()

  _tagSetter : (tag) ->
    return =>
      @setState { tag }

  _unsetTag : ->
    @setState { tag : null }

  _isCommittable : ->
    return !!@state.value.trim()

  _commitIfAllowed : ->
    if @_isCommittable()
      @props.addIngredient @state.value.trim(), @state.tag

  _onChange : (e) ->
    @setState { value : e.target.value }

}

EditableIngredientsPage = React.createClass {
  displayName : 'EditableIngredientsPage'

  mixins : [
    ReduxMixin {
      editableRecipe : [ 'name', 'ingredients' ]
      ingredients    : [ 'ingredientsByTag', 'allAlphabeticalIngredients' ]
    }
  ]

  propTypes :
    onClose : React.PropTypes.func.isRequired
    back    : React.PropTypes.func.isRequired
    next    : React.PropTypes.func.isRequired

  render : ->
    ingredientNodes = _.map @state.ingredients, (ingredient, index) =>
      if ingredient.isEditing
        ingredientNode = <EditableIngredient
          addIngredient={@_ingredientAdder index}
          ingredientsByTag={@state.ingredientsByTag}
          allAlphabeticalIngredients={@state.allAlphabeticalIngredients}
        />
      else
        ingredientNode = <MeasuredIngredient {...ingredient.display}/>

      return <Deletable
        onDelete={@_ingredientDeleter index}
        key="tag-#{ingredient.tag ? ingredient.display?.displayIngredient}"
      >
        {ingredientNode}
      </Deletable>

    <div className='editable-recipe-page ingredients-page fixed-header-footer'>
      <NavigationHeader onClose={@props.onClose} backTitle={'"' + @state.name + '"'} goBack={@props.back}/>
      <div className='fixed-content-pane'>
        <div className='ingredients-list'>
          {ingredientNodes}
        </div>
        <div className={classnames 'new-ingredient-button', { 'disabled' : @_anyAreEditing() }} onTouchTap={@_addEmptyIngredient}>
          <i className='fa fa-plus-circle'/>
          <span>New Ingredient</span>
        </div>
        <div className={classnames 'next-button', { 'disabled' : not @_isEnabled() }} onTouchTap={@_nextIfEnabled}>
          <span className='next-text'>Next</span>
          <i className='fa fa-arrow-right'/>
        </div>
      </div>
    </div>

  _anyAreEditing : ->
    return _.any @state.ingredients, 'isEditing'

  _isEnabled : ->
    return @state.ingredients.length > 0 and not _.any(@state.ingredients, 'isEditing')

  _nextIfEnabled : ->
    if @_isEnabled()
      @props.next()

  _addEmptyIngredient : ->
    return if @_anyAreEditing()

    store.dispatch {
      type : 'add-ingredient'
    }

  _ingredientAdder : (index) ->
    return (rawText, tag) =>
      store.dispatch {
        type : 'commit-ingredient'
        index
        rawText
        tag
      }

  _ingredientDeleter : (index) ->
    return =>
      store.dispatch {
        type : 'delete-ingredient'
        index
      }
}

EditableBaseLiquorPage = React.createClass {
  displayName : 'EditableBaseLiquorPage'

  mixins : [
    ReduxMixin {
      editableRecipe : [ 'ingredients', 'base' ]
    }
  ]

  propTypes :
    onClose : React.PropTypes.func.isRequired
    back    : React.PropTypes.func.isRequired
    next    : React.PropTypes.func.isRequired

  render : ->
    backTitle = "#{@state.ingredients.length} ingredient"
    if @state.ingredients.length != 1
      backTitle += 's'

    <div className='editable-recipe-page base-tag-page fixed-header-footer'>
      <NavigationHeader onClose={@props.onClose} backTitle={backTitle} goBack={@props.back}/>
      <div className='fixed-content-pane'>
        <div className='page-title'>Base ingredient(s)</div>
        <List>
          {for tag in definitions.BASE_LIQUORS
            <List.Item
              className={classnames 'base-liquor-option', { 'is-selected' : tag in @state.base }}
              onTouchTap={@_tagToggler tag}
              key="tag-#{tag}"
            >
              {BASE_TITLES_BY_TAG[tag]}
              <i className='fa fa-check-circle'/>
            </List.Item>}
        </List>
        <div className={classnames 'next-button', { 'disabled' : not @_isEnabled() }} onTouchTap={@_nextIfEnabled}>
          <span className='next-text'>Next</span>
          <i className='fa fa-arrow-right'/>
        </div>
      </div>
    </div>

  _isEnabled : ->
    return @state.base.length > 0

  _nextIfEnabled : ->
    if @_isEnabled()
      @props.next()

  _tagToggler : (tag) ->
    return =>
      store.dispatch {
        type : 'toggle-base-liquor-tag'
        tag
      }
}


EditableTextPage = React.createClass {
  displayName : 'EditableTextPage'

  mixins : [
    ReduxMixin {
      editableRecipe : [ 'base', 'instructions', 'notes' ]
    }
  ]

  propTypes :
    onClose : React.PropTypes.func.isRequired
    back    : React.PropTypes.func.isRequired
    next    : React.PropTypes.func.isRequired

  render : ->
    if @state.base.length == 1
      backTitle = "#{BASE_TITLES_BY_TAG[@state.base[0]]}-based"
    else
      backTitle = "#{@state.base.length} base liquors"
    <div className='editable-recipe-page text-page fixed-header-footer'>
      <NavigationHeader onClose={@props.onClose} backTitle={backTitle} goBack={@props.back}/>
      <div className='fixed-content-pane'>
        <textarea
          className='editable-text-area'
          placeholder='Instructions...'
          onChange={@_setInstructions}
          value={@state.instructions}
          ref='instructions'
        />
        <textarea
          className='editable-text-area'
          placeholder='Notes (optional)...'
          onChange={@_setNotes}
          value={@state.notes}
          ref='notes'
        />
        <div className={classnames 'next-button', { 'disabled' : not @_isEnabled() }} onTouchTap={@_nextIfEnabled}>
          <span className='next-text'>Next</span>
          <i className='fa fa-arrow-right'/>
        </div>
      </div>
    </div>

  _isEnabled : ->
    return @state.instructions.length

  _nextIfEnabled : ->
    if @_isEnabled()
      @props.next()

  _setInstructions : (e) ->
    store.dispatch {
      type         : 'set-instructions'
      instructions : e.target.value
    }

  _setNotes : (e) ->
    store.dispatch {
      type  : 'set-notes'
      notes : e.target.value
    }
}


PreviewPage = React.createClass {
  displayName : 'PreviewPage'

  propTypes :
    onClose : React.PropTypes.func.isRequired
    back    : React.PropTypes.func.isRequired
    next    : React.PropTypes.func.isRequired
    recipe  : React.PropTypes.object

  render : ->
    <div className='editable-recipe-page preview-page fixed-header-footer'>
      <NavigationHeader onClose={@props.onClose} backTitle='Instructions' goBack={@props.back}/>
      <div className='fixed-content-pane'>
        <RecipeView recipe={@props.recipe}/>
      </div>
      <div className='next-button fixed-footer' onTouchTap={@props.next}>
        <span className='next-text'>Done</span>
        <i className='fa fa-check'/>
      </div>
    </div>
}

EditableRecipeView = React.createClass {
  displayName : 'EditableRecipeView'

  propTypes :
    onClose : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      editableRecipe : 'currentPage'
    }
  ]

  render : ->
    return switch @state.currentPage
      when EditableRecipePage.NAME
        <EditableNamePage
          next={@_makePageSwitcher(EditableRecipePage.INGREDIENTS)}
          onClose={@props.onClose}}
        />
      when EditableRecipePage.INGREDIENTS
        <EditableIngredientsPage
          back={@_makePageSwitcher(EditableRecipePage.NAME)}
          next={@_makePageSwitcher(EditableRecipePage.BASE)}
          onClose={@props.onClose}}
        />
      when EditableRecipePage.BASE
        <EditableBaseLiquorPage
          back={@_makePageSwitcher(EditableRecipePage.INGREDIENTS)}
          next={@_makePageSwitcher(EditableRecipePage.TEXT)}
          onClose={@props.onClose}}
        />
      when EditableRecipePage.TEXT
        <EditableTextPage
          back={@_makePageSwitcher(EditableRecipePage.BASE)}
          next={@_makePageSwitcher(EditableRecipePage.PREVIEW)}
          onClose={@props.onClose}}
        />
      when EditableRecipePage.PREVIEW
        <PreviewPage
          back={@_makePageSwitcher(EditableRecipePage.TEXT)}
          next={@_finish}
          onClose={@props.onClose}}
          recipe={@_constructRecipe()}
        />

  _makePageSwitcher : (page) ->
    return =>
      store.dispatch {
        type : 'set-editable-recipe-page'
        page
      }

  _finish : ->
    store.dispatch {
      type   : 'save-recipe'
      recipe : @_constructRecipe()
    }

    @props.onClose()

  _constructRecipe : ->
    editableRecipeState = store.getState().editableRecipe

    ingredients = _.map editableRecipeState.ingredients, (ingredient) =>
      return _.pick _.extend({ tag : ingredient.tag }, ingredient.display), _.identity

    recipe = _.chain editableRecipeState
      .pick 'name', 'instructions', 'notes', 'base'
      .extend { ingredients, isCustom : true }
      .pick _.identity
      .value()

    return normalization.normalizeRecipe recipe
}

module.exports = EditableRecipeView

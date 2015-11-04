# TODO: This GIANT file needs to be broken up once it's clearer what's staying and what's not.

_          = require 'lodash'
React      = require 'react'
classnames = require 'classnames'

ReduxMixin = require '../mixins/ReduxMixin'
# DerivedValueMixins = require '../mixins/DerivedValueMixins'

normalization = require '../../shared/normalization'
definitions   = require '../../shared/definitions'
assert        = require '../../shared/tinyassert'

List              = require '../components/List'
FixedHeaderFooter = require '../components/FixedHeaderFooter'
Deletable         = require '../components/Deletable'

store         = require '../store'
overlayViews  = require '../overlayViews'

MeasuredIngredient = require './MeasuredIngredient'
RecipeView         = require './RecipeView'

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
    overlayViews.flyup.hide()
    store.dispatch {
      type : 'clear-editable-recipe'
    }
}

EditableNamePage = React.createClass {
  displayName : 'EditableNamePage'

  mixins : [
    ReduxMixin {
      editableRecipe : 'name'
    }
  ]

  propTypes :
    next : React.PropTypes.func.isRequired

  render : ->
    <FixedHeaderFooter
      header={<NavigationHeader/>}
      className='editable-recipe-page name-page'
    >
      <div className='page-content'>
        <div className='page-title'>Add a Recipe</div>
        <input
          type='text'
          placeholder='Name...'
          autoCorrect='off'
          autoCapitalize='on'
          autoComplete='off'
          spellCheck='false'
          ref='input'
          value={@state.name}
          onChange={@_onChange}
          onTouchTap={@_focus}
        />
        <div className={classnames 'next-button', { 'disabled' : not @_isEnabled() }} onTouchTap={@_nextIfEnabled}>
          <span className='next-text'>Next</span>
          <i className='fa fa-arrow-right'/>
        </div>
      </div>
    </FixedHeaderFooter>

  _focus : ->
    @refs.input.getDOMNode().focus()

  # mixin-ify this kind of stuff probably
  _isEnabled : ->
    return !!@state.name

  _nextIfEnabled : ->
    if @_isEnabled()
      store.dispatch {
        type : 'set-name'
        name : @state.name.trim()
      }
      @props.next()

  _onChange : (e) ->
    store.dispatch {
      type : 'set-name'
      name : e.target.value
    }
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
    @refs.input.getDOMNode().focus()

  _dismissKeyboard : ->
    @refs.input.getDOMNode().blur()

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
    back : React.PropTypes.func.isRequired
    next : React.PropTypes.func.isRequired

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

    <FixedHeaderFooter
      header={<NavigationHeader backTitle={'"' + @state.name + '"'} goBack={@props.back}/>}
      className='editable-recipe-page ingredients-page'
    >
      <div className='page-content'>
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
    </FixedHeaderFooter>

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
    back : React.PropTypes.func.isRequired
    next : React.PropTypes.func.isRequired

  render : ->
    backTitle = "#{@state.ingredients.length} ingredient"
    if @state.ingredients.length != 1
      backTitle += 's'

    <FixedHeaderFooter
      header={<NavigationHeader backTitle={backTitle} goBack={@props.back}/>}
      className='editable-recipe-page base-tag-page'
    >
      <div className='page-content'>
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
    </FixedHeaderFooter>

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
    back : React.PropTypes.func.isRequired
    next : React.PropTypes.func.isRequired

  render : ->
    if @state.base.length == 1
      backTitle = "#{BASE_TITLES_BY_TAG[@state.base[0]]}-based"
    else
      backTitle = "#{@state.base.length} base liquors"

    <FixedHeaderFooter
      header={<NavigationHeader backTitle={backTitle} goBack={@props.back}/>}
      className='editable-recipe-page text-page'
    >
      <div className='page-content'>
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
    </FixedHeaderFooter>

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
    back   : React.PropTypes.func.isRequired
    next   : React.PropTypes.func.isRequired
    recipe : React.PropTypes.object

  render : ->
    footer = <div className='next-button' onTouchTap={@props.next}>
      <span className='next-text'>Done</span>
      <i className='fa fa-check'/>
    </div>
    <FixedHeaderFooter
      header={<NavigationHeader backTitle='Instructions' goBack={@props.back}/>}
      footer={footer}
      className='editable-recipe-page preview-page'
    >
      <div className='page-content'>
        <RecipeView recipe={@props.recipe}/>
      </div>
    </FixedHeaderFooter>
}

EditableRecipePage =
  NAME        : 'name'
  INGREDIENTS : 'ingredients'
  TEXT        : 'text'
  BASE        : 'base'
  PREVIEW     : 'preview'

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
          next={@_makePageSwitcher(EditableRecipePage.BASE)}
        />
      when EditableRecipePage.BASE
        <EditableBaseLiquorPage
          back={@_makePageSwitcher(EditableRecipePage.INGREDIENTS)}
          next={@_makePageSwitcher(EditableRecipePage.TEXT)}
        />
      when EditableRecipePage.TEXT
        <EditableTextPage
          back={@_makePageSwitcher(EditableRecipePage.BASE)}
          next={@_makePageSwitcher(EditableRecipePage.PREVIEW)}
        />
      when EditableRecipePage.PREVIEW
        <PreviewPage
          back={@_makePageSwitcher(EditableRecipePage.TEXT)}
          next={@_finish}
          recipe={@_constructRecipe()}
        />

  _makePageSwitcher : (targetPage) ->
    return =>
      @setState { currentPage : targetPage }

  _finish : ->
    overlayViews.flyup.hide()
    store.dispatch {
      type   : 'save-recipe'
      recipe : @_constructRecipe()
    }

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

_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

normalization = require '../../shared/normalization'

{ IngredientStore, EditableRecipeStore } = require '../stores'

List              = require '../components/List'
FixedHeaderFooter = require '../components/FixedHeaderFooter'
Deletable         = require '../components/Deletable'

FluxMixin = require '../mixins/FluxMixin'

AppDispatcher = require '../AppDispatcher'

MeasuredIngredient = require './MeasuredIngredient'
RecipeView         = require './RecipeView'

BASE_TAGS = {
  'gin'     : 'Gin'
  'vodka'   : 'Vodka'
  'whiskey' : 'Whiskey'
  'rum'     : 'Rum'
  'brandy'  : 'Brandy/Cognac'
  'tequila' : 'Tequila/Mezcal'
  'liqueur' : 'Liqueur/Other'
}

# TODO: make IconButton class?
# TODO: chooser for base liquor!
# TODO: clicking back into ingredients to edit them
# TODO: show what "type of" it is in the final display
# TODO: deselect input when you scroll through to find the tag
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
    AppDispatcher.dispatch {
      type : 'hide-flyup'
    }
    AppDispatcher.dispatch {
      type : 'clear-editable-recipe'
    }
}

EditableNamePage = React.createClass {
  displayName : 'EditableNamePage'

  mixins : [
    FluxMixin EditableRecipeStore, 'name'
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
          onTouchTap={@focus}
        />
        <div className={classnames 'next-button', { 'disabled' : not @_isEnabled() }} onTouchTap={@_nextIfEnabled}>
          <span className='next-text'>Next</span>
          <i className='fa fa-arrow-right'/>
        </div>
      </div>
    </FixedHeaderFooter>

  focus : ->
    @refs.input.getDOMNode().focus()

  # mixin-ify this kind of stuff probably
  _isEnabled : ->
    return !!@state.name

  _nextIfEnabled : ->
    if @_isEnabled()
      AppDispatcher.dispatch {
        type : 'set-name'
        name : @state.name.trim()
      }
      @props.next()

  _onChange : (e) ->
    AppDispatcher.dispatch {
      type : 'set-name'
      name : e.target.value
    }
}

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

  propTypes :
    addIngredient : React.PropTypes.func.isRequired

  getInitialState : -> {
    tag   : null
    value : ''
  }

  render : ->
    if @state.tag?
      ingredientSelector = <List.Item>
        {IngredientStore.ingredientsByTag[@state.tag].display}
        <i className='fa fa-check-circle'/>
      </List.Item>
    else
      ingredientSelector = _.map IngredientStore.allAlphabeticalIngredients, ({ display, tag }) =>
        <List.Item onTouchTap={@_tagSetter tag} key="tag-#{tag}">{display}</List.Item>

    <div className='editable-ingredient2'>
      <div className='input-line'>
        <input
          type='text'
          placeholder='ex: 1 oz gin'
          autoCorrect='on'
          autoCapitalize='off'
          autoComplete='off'
          spellCheck='false'
          ref='input'
          value={@state.value}
          onChange={@_onChange}
          onTouchTap={@focus}
        />
        <div
          className={classnames 'done-button', { 'disabled' : not @_isCommittable() }}
          onTouchTap={@_commitIfAllowed}
        >
          Done
        </div>
      </div>
      <div className='ingredient-list-header'>A Type Of</div>
      <List className='ingredient-group-list'>
        {ingredientSelector}
      </List>
    </div>

  focus : ->
    @refs.input.getDOMNode().focus()

  _tagSetter : (tag) ->
    return =>
      @setState { tag }

  _isCommittable : ->
    return !!@state.value.trim()

  _commitIfAllowed : ->
    @props.addIngredient @state.value.trim(), @state.tag

  _onChange : (e) ->
    @setState { value : e.target.value }

}

EditableIngredientsPage = React.createClass {
  displayName : 'EditableIngredientsPage'

  mixins : [
    FluxMixin EditableRecipeStore, 'name', 'ingredients'
  ]

  propTypes :
    back : React.PropTypes.func.isRequired
    next : React.PropTypes.func.isRequired

  render : ->
    ingredientNodes = _.map @state.ingredients, (ingredient, index) =>
      if ingredient.isEditing
        ingredientNode = <EditableIngredient addIngredient={@_ingredientAdder index}/>
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

    AppDispatcher.dispatch {
      type : 'add-ingredient'
    }

  _ingredientAdder : (index) ->
    return (rawText, tag) =>
      AppDispatcher.dispatch {
        type : 'commit-ingredient'
        index
        rawText
        tag
      }

  _ingredientDeleter : (index) ->
    return =>
      AppDispatcher.dispatch {
        type : 'delete-ingredient'
        index
      }
}

EditableBaseLiquorPage = React.createClass {
  displayName : 'EditableBaseLiquorPage'

  mixins : [
    FluxMixin EditableRecipeStore, 'ingredients', 'base'
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
          {for tag, title of BASE_TAGS
            <List.Item
              className={classnames 'base-liquor-option', { 'is-selected' : tag in @state.base }}
              onTouchTap={@_tagToggler tag}
              key="tag-#{tag}"
            >
              {title}
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
      AppDispatcher.dispatch {
        type : 'toggle-base-liquor-tag'
        tag
      }
}


EditableTextPage = React.createClass {
  displayName : 'EditableTextPage'

  mixins : [
    FluxMixin EditableRecipeStore, 'base', 'instructions', 'notes'
  ]

  propTypes :
    back : React.PropTypes.func.isRequired
    next : React.PropTypes.func.isRequired

  render : ->
    if @state.base.length == 1
      backTitle = "#{BASE_TAGS[@state.base[0]]}-based"
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
    AppDispatcher.dispatch {
      type         : 'set-instructions'
      instructions : e.target.value
    }

  _setNotes : (e) ->
    AppDispatcher.dispatch {
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
    # Well, doing two things here certainly seems weird. Time for an Action?
    AppDispatcher.dispatch {
      type : 'hide-flyup'
    }
    AppDispatcher.dispatch {
      type   : 'save-recipe'
      recipe : @_constructRecipe()
    }

  _constructRecipe : ->
    ingredients = _.map EditableRecipeStore.ingredients, (ingredient) =>
      return _.pick _.extend({ tag : ingredient.tag }, ingredient.display), _.identity
    recipe = _.chain EditableRecipeStore
      .pick 'name', 'instructions', 'notes', 'base'
      .extend { ingredients, isCustom : true }
      .pick _.identity
      .value()
    return normalization.normalizeRecipe recipe
}

module.exports = EditableRecipeView

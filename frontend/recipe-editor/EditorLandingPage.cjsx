_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

store = require '../store'

ReduxMixin = require '../mixins/ReduxMixin'

NavigationHeader = require './NavigationHeader'
NextButton       = require './NextButton'
GuidedWorkflow   = require './GuidedWorkflow'
ProseWorkflow    = require './ProseWorkflow'
RecipeIdWorkflow = require './RecipeIdWorkflow'

{ loadRecipe } = require './recipeEditorActions'

EditorLandingPage = React.createClass {
  displayName : 'EditorLandingPage'

  mixins : [
    ReduxMixin {
      recipeEditor : [ 'name', 'providedProse', 'providedRecipeId' ]
    }
    PureRenderMixin
  ]

  propTypes :
    onClose : React.PropTypes.func.isRequired

  getInitialState : -> {
    focusedInput : null
  }

  render : ->
    <div className={classnames 'editor-landing-page fixed-header-footer', {
      'is-any-expanded' : !!@state.focusedInput
    }} ref='container'>
      <NavigationHeader onClose={@props.onClose} className='fixed-header'/>
      <div className='fixed-content-pane'>
        <div className={classnames 'add-recipe-section new-recipe', {
          'is-expanded' : @state.focusedInput == 'nameInput'
        }}>
          <div className='section-title'>Create New Drink</div>
          <div className='help-text'>Create a new recipe, step by step.</div>
          <input
            type='text'
            placeholder='Gin & Tonic'
            autoCorrect='off'
            autoCapitalize='on'
            autoComplete='off'
            spellCheck='false'
            ref='nameInput'
            value={@state.name}
            onChange={@_onChangeName}
            onTouchTap={@_makeFocuser 'nameInput'}
            onFocus={@_makeOnFocus 'nameInput'}
            onBlur={@_onBlur}
          />
          <NextButton
            text='Create'
            isEnabled={!!@state.name}
            onNext={@_goToGuided}
          />
        </div>
        <div className={classnames 'add-recipe-section add-prose', {
          'is-expanded' : @state.focusedInput == 'proseInput'
        }}>
          <div className='section-title'>Recipe from Text</div>
          <div className='help-text'>Paste an existing recipe to get started faster.</div>
          <textarea
            placeholder='
            Martini\n
            \n
            2 oz gin\n
            vermouth\n
            \n
            Shaken, not stirred.
            '
            autoCorrect='off'
            autoCapitalize='on'
            autoComplete='off'
            spellCheck='false'
            ref='proseInput'
            value={@state.providedProse}
            onChange={@_onChangeProse}
            onTouchTap={@_makeFocuser 'proseInput'}
            onFocus={@_makeOnFocus 'proseInput'}
            onBlur={@_onBlur}
          />
          <NextButton
            text='Parse'
            isEnabled={!!@state.providedProse}
            onNext={@_goToProse}
          />
        </div>
        <div className={classnames 'add-recipe-section add-id', {
          'is-expanded' : @state.focusedInput == 'idInput'
        }}>
          <div className='section-title'>Use Code</div>
          <div className='help-text'>Use a code copied from another spiritgui.de recipe.</div>
          <input
            type='text'
            placeholder='a6be7da3f0843f7c84de9bdb771f7f08'
            autoCorrect='off'
            autoCapitalize='off'
            autoComplete='off'
            spellCheck='false'
            ref='idInput'
            value={@state.providedRecipeId}
            onChange={@_onChangeProvidedId}
            onTouchTap={@_makeFocuser 'idInput'}
            onFocus={@_makeOnFocus 'idInput'}
            onBlur={@_onBlur}
          />
          <NextButton
            text='Fetch'
            isEnabled={!!@state.providedRecipeId}
            onNext={@_goToId}
          />
        </div>
      </div>
    </div>

  componentWillMount : ->
    @_makeFocuser = _.memoize @_makeFocuser
    @_makeOnFocus = _.memoize @_makeOnFocus

  _makeFocuser : (refName) ->
    return =>
      @refs[refName].focus()

  _makeOnFocus : (refName) ->
    return =>
      @setState { focusedInput : refName }

  _onBlur : ->
    activeElement = document.activeElement
    thisElement = @refs.container
    while activeElement? and activeElement != thisElement
      activeElement = activeElement.parentNode
    if not activeElement
      @setState { focusedInput : null }

  _onChangeName : (e) ->
    store.dispatch {
      type : 'set-name'
      name : e.target.value
    }

  _goToGuided : ->
    store.dispatch {
      type      : 'start-guided-workflow'
      firstStep : GuidedWorkflow.FIRST_STEP
    }

  _onChangeProse : (e) ->
    store.dispatch {
      type : 'set-prose'
      text : e.target.value
    }

  _goToProse : ->
    store.dispatch {
      type      : 'start-prose-workflow'
      firstStep : ProseWorkflow.FIRST_STEP
    }

  _onChangeProvidedId : (e) ->
    store.dispatch {
      type     : 'set-provided-recipe-id'
      recipeId : e.target.value
    }

  _goToId : ->
    store.dispatch loadRecipe(@state.providedRecipeId.trim())
    .then ->
      store.dispatch {
        type      : 'start-id-workflow'
        firstStep : RecipeIdWorkflow.FIRST_STEP_SUCCESS
      }
    .catch ->
      store.dispatch {
        type      : 'start-id-workflow'
        firstStep : RecipeIdWorkflow.FIRST_STEP_FAIL
      }
}

module.exports = EditorLandingPage

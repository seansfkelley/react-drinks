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

  render : ->
    <div className='editor-landing-page fixed-header-footer'>
      <NavigationHeader onClose={@props.onClose} className='fixed-header'/>
      <div className='fixed-content-pane'>
        <div className='add-recipe-section new-recipe'>
          <div className='section-title'>Create New Drink</div>
          <input
            type='text'
            placeholder='Name...'
            autoCorrect='off'
            autoCapitalize='on'
            autoComplete='off'
            spellCheck='false'
            ref='nameInput'
            value={@state.name}
            onChange={@_onChangeName}
            onTouchTap={@_makeFocuser 'nameInput'}
          />
          <NextButton
            isEnabled={!!@state.name}
            onNext={@_goToGuided}
          />
        </div>
        <div className='add-recipe-section add-prose'>
          <div className='section-title'>Recipe from Text</div>
          <textarea
            placeholder='Recipe text...'
            autoCorrect='off'
            autoCapitalize='on'
            autoComplete='off'
            spellCheck='false'
            ref='proseInput'
            value={@state.providedProse}
            onChange={@_onChangeProse}
            onTouchTap={@_makeFocuser 'proseInput'}
          />
          <NextButton
            isEnabled={!!@state.providedProse}
            onNext={@_goToProse}
          />
        </div>
        <div className='add-recipe-section add-id'>
          <div className='section-title'>Use Code</div>
          <input
            type='text'
            placeholder='Code...'
            autoCorrect='off'
            autoCapitalize='off'
            autoComplete='off'
            spellCheck='false'
            ref='idInput'
            value={@state.providedRecipeId}
            onChange={@_onChangeProvidedId}
            onTouchTap={@_makeFocuser 'idInput'}
          />
          <NextButton
            isEnabled={!!@state.providedRecipeId}
            onNext={@_goToId}
            text='Fetch'
          />
        </div>
      </div>
    </div>

  componentWillMount : ->
    @_makeFocuser = _.memoize @_makeFocuser

  _makeFocuser :(refName) ->
    return =>
      @refs[refName].focus()

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

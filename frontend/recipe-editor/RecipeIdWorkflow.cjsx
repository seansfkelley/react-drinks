React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'
classnames      = require 'classnames'

ReduxMixin = require '../mixins/ReduxMixin'

store = require '../store'

NavigationHeader = require './NavigationHeader'
IdEntry          = require './IdEntry'

RecipeView = require '../recipes/RecipeView'
ButtonBar  = require '../components/ButtonBar'

{ loadRecipe } = require './recipeEditorActions'

WorkflowStep =
  ID      : 'id'
  PREVIEW : 'preview'

RecipeIdWorkflow = React.createClass {
  displayName : 'RecipeIdWorkflow'

  propTypes :
    onClose   : React.PropTypes.func.isRequired
    className : React.PropTypes.string

  mixins : [
    ReduxMixin {
      recipeEditor : [ 'currentStep', 'providedRecipeId', 'isLoadingRecipe', 'loadedRecipe', 'recipeLoadFailed' ]
    }
    PureRenderMixin
  ]

  render : ->
    <div className={classnames 'fixed-header-footer recipe-id-workflow', @props.className}>
      {@_getNavigationHeader()}
      {@_getPageContent()}
      {@_getFooterButtons()}
    </div>

  _getNavigationHeader : ->
    props = _.extend {
      onClose   : @_onClose
      className : 'fixed-header'
    }, switch @state.currentStep
      when WorkflowStep.PREVIEW then {
        onPrevious    : @_goToIdStep
        previousTitle : 'Enter Code'
      }

    return <NavigationHeader {...props}/>

  _getPageContent : ->
    return switch @state.currentStep
      when WorkflowStep.ID
        <IdEntry
          value={@state.providedRecipeId}
          onChange={@_onIdChange}
          isValid={not @state.recipeLoadFailed}
          isLoading={@state.isLoadingRecipe}
          className='fixed-content-pane'
        />
      when WorkflowStep.PREVIEW
        <RecipeView
          recipe={@state.loadedRecipe}
          className='fixed-content-pane'
        />

  _getFooterButtons : ->
    buttons = switch @state.currentStep
      when WorkflowStep.ID then [
        icon       : if @state.isLoadingRecipe then 'fa-refresh fa-spin' else 'fa-download'
        text       : 'Get Recipe'
        onTouchTap : @_tryLoad
        enabled    : not @state.isLoadingRecipe and @state.providedRecipeId.length == 32 # md5
      ]
      when WorkflowStep.PREVIEW then [
        icon       : 'fa-check'
        text       : 'Save'
        onTouchTap : @_finish
      ]

    return <ButtonBar
      buttons={buttons}
      className='fixed-footer'
    />

  _onClose : ->
    # Clear the store!
    @props.onClose()

  _onIdChange : (recipeId) ->
    store.dispatch {
      type : 'set-provided-recipe-id'
      recipeId
    }

    store.dispatch {
      type : 'clear-load-failure-flag'
    }

  _goToIdStep : ->
    store.dispatch {
      type : 'set-recipe-editor-step'
      step : WorkflowStep.ID
    }

  _tryLoad : ->
    store.dispatch loadRecipe(@state.providedRecipeId)
    .then ->
      store.dispatch {
        type : 'set-recipe-editor-step'
        step : WorkflowStep.PREVIEW
      }
    .catch ->
      store.dispatch {
        type : 'set-recipe-editor-step'
        step : WorkflowStep.ID
      }

  _finish : ->
    store.dispatch {
      type   : 'saved-recipe'
      recipe : _.extend { recipeId : @state.providedRecipeId }, @state.loadedRecipe
    }
    @props.onClose()
}

RecipeIdWorkflow.FIRST_STEP_SUCCESS = WorkflowStep.PREVIEW
RecipeIdWorkflow.FIRST_STEP_FAIL = WorkflowStep.ID

module.exports = RecipeIdWorkflow

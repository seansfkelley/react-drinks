_          = require 'lodash'
React      = require 'react'
classnames = require 'classnames'

ReduxMixin = require '../mixins/ReduxMixin'

store = require '../store'

definitions = require '../../shared/definitions'

NavigationHeader = require './NavigationHeader'
RecipeView       = require '../recipes/RecipeView'

editableRecipeActions = require './editableRecipeActions'
recipeFromStore       = require './recipeFromStore'

###
(prose)
  -> preview
    -> (done)
    -> prose-retry -> preview...
    -> name -> ingredients -> base -> text -> preview -> (done)

refactor *Pages to just be the main content
refactor store to just be a currentWorkflow and workflowData
- or or or, it should be a nested store with three other reducers

###

WorkflowStep =
  # Landing page for this workflow.
  INITIAL_PREVIEW : 'initial-preview'

  # Fork 1.
  PROSE           : 'prose'
  PROSE_PREVIEW   : 'prose-preview'

  # Fork 2.
  NAME            : 'name'
  INGREDIENTS     : 'ingredients'
  BASE            : 'base'
  TEXT            : 'text'
  REGULAR_PREVIEW : 'regular-preview'

PREVIOUS_STEPS =
  "#{WorkflowStep.PROSE_PREVIEW}"   : WorkflowStep.PROSE
  "#{WorkflowStep.INGREDIENTS}"     : WorkflowStep.NAME
  "#{WorkflowStep.BASE}"            : WorkflowStep.INGREDIENTS
  "#{WorkflowStep.TEXT}"            : WorkflowStep.BASE
  "#{WorkflowStep.REGULAR_PREVIEW}" : WorkflowStep.TEXT

PREVIOUS_TEXT_FOR =
  "#{WorkflowStep.PROSE}"       : (state) -> 'Text...'
  "#{WorkflowStep.NAME}"        : (state) -> "\"#{state.name}\""
  "#{WorkflowStep.INGREDIENTS}" : (state) ->
    return "#{state.ingredients.length} ingredient#{if state.ingredients.length == 0 then '' else 's'}"
  "#{WorkflowStep.BASE}"        : (state) ->
    if state.base.length == 1
      return "#{definitions.BASE_TITLES_BY_TAG[state.base[0]]}-based"
    else
      return "#{@state.base.length} base liquors"
  "#{WorkflowStep.TEXT}"        : (state) -> 'Instructions'

FromProseWorkflow = React.createClass {
  displayName : 'FromProseWorkflow'

  propTypes :
    onClose   : React.PropTypes.func.isRequired
    className : React.PropTypes.string

  mixins : [
    ReduxMixin {
      editableRecipe : [ 'currentPage', 'ingredients', 'name', 'base', 'saving', 'originalProse' ]
    }
  ]

  render : ->
    <div className={classnames 'fixed-header-footer', @props.className}>
      {@_getNavigationHeader()}
      {@_getPageContent()}
      {@_getFooterButtons()}
    </div>

  _getNavigationHeader : ->
    previousPage = PREVIOUS_STEPS[@state.currentPage]
    if previousPage
      onPrevious    = _makePageSwitcher previousPage
      previousTitle = PREVIOUS_TEXT_FOR[previousPage](@state)

    return <NavigationHeader
      onClose={@_onClose}
      onPrevious={onPrevious}
      previousTitle={previousTitle}
      className='fixed-header'
    />

  _getPageContent : ->
    return switch @state.currentPage
      when WorkflowStep.INITIAL_PREVIEW, WorkflowStep.PROSE_PREVIEW, WorkflowStep.REGULAR_PREVIEW
        <RecipeView recipe={recipeFromStore store}/>

  _getFooterButtons : ->

  _onClose : ->
    # Clear the store!
    @props.onClose()

  _makePageSwitcher : (page) ->
    return =>
      store.dispatch {
        type : 'set-editable-recipe-page'
        page
      }

  _finish : ->
    recipe = recipeFromStore store.getState().editableRecipe
    store.dispatch editableRecipeActions.saveRecipe(recipe)
    .then =>
      @props.onClose()
}

FromProseWorkflow.FIRST_PAGE = WorkflowStep.INITIAL_PREVIEW

module.exports = FromProseWorkflow

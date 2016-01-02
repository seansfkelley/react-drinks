_       = require 'lodash'
React   = require 'react'

ReduxMixin = require '../mixins/ReduxMixin'

store                  = require '../store'
EditableRecipePageType = require '../EditableRecipePageType'

definitions = require '../../shared/definitions'

EditableNamePage        = require './EditableNamePage'
EditableIngredientsPage = require './EditableIngredientsPage'
EditableBaseLiquorPage  = require './EditableBaseLiquorPage'
EditableTextPage        = require './EditableTextPage'
PreviewPage             = require './PreviewPage'

editableRecipeActions = require './editableRecipeActions'
recipeFromStore       = require './recipeFromStore'

###
possible flows are as follows:

landing
  (new)
  -> name -> ingredients -> base -> text -> preview -> (done)

  (prose)
  -> preview
    -> (done)
    -> prose-retry -> preview...
    -> name -> ingredients -> base -> text -> preview...

###

FromProseWorkflow = React.createClass {
  displayName : 'FromProseWorkflow'

  propTypes :
    onClose : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      editableRecipe : [ 'currentPage', 'ingredients', 'name', 'base', 'saving', 'originalProse' ]
    }
  ]

  render : ->
    return switch @state.currentPage

      when EditableRecipePageType.PROSE
        # ...

      # TODO: This is kind of wonky; we want two buttons on the preview page.
      # Suggested resolution: tool around with the design a bit; I suspect the
      # "text + fat arrow" is not the best way to make a button, and I further
      # suspect that the new versions of the buttons will be more amenable to
      # factoring-out.
      when EditableRecipePageType.PROSE_PREVIEW
        <PreviewPage
          previousTitle='Instructions'
          onPrevious={@_makePageSwitcher(EditableRecipePageType.PROSE)}
          # Hm, want two of these...
          onNext={@_finish}
          onClose={@props.onClose}}
          recipe={recipeFromStore store.getState().editableRecipe}
        />

      when EditableRecipePageType.NAME
        <EditableNamePage
          onNext={@_makePageSwitcher(EditableRecipePageType.INGREDIENTS)}
          onClose={@props.onClose}}
        />

      when EditableRecipePageType.INGREDIENTS
        <EditableIngredientsPage
          previousTitle={'"' + @state.name + '"'}
          onPrevious={@_makePageSwitcher(EditableRecipePageType.NAME)}
          onNext={@_makePageSwitcher(EditableRecipePageType.BASE)}
          onClose={@props.onClose}}
        />

      when EditableRecipePageType.BASE
        previousTitle = "#{@state.ingredients.length} ingredient"
        if @state.ingredients.length != 1
          previousTitle += 's'
        <EditableBaseLiquorPage
          previousTitle={previousTitle}
          onPrevious={@_makePageSwitcher(EditableRecipePageType.INGREDIENTS)}
          onNext={@_makePageSwitcher(EditableRecipePageType.TEXT)}
          onClose={@props.onClose}}
        />

      when EditableRecipePageType.TEXT
        if @state.base.length == 1
          previousTitle = "#{definitions.BASE_TITLES_BY_TAG[@state.base[0]]}-based"
        else
          previousTitle = "#{@state.base.length} base liquors"
        <EditableTextPage
          previousTitle={previousTitle}
          onPrevious={@_makePageSwitcher(EditableRecipePageType.BASE)}
          onNext={@_makePageSwitcher(EditableRecipePageType.PREVIEW)}
          onClose={@props.onClose}}
        />

      when EditableRecipePageType.PREVIEW
        <PreviewPage
          previousTitle='Instructions'
          onPrevious={@_makePageSwitcher(EditableRecipePageType.TEXT)}
          onNext={@_finish}
          onClose={@props.onClose}}
          recipe={recipeFromStore store.getState().editableRecipe}
          isSaving={@state.saving}
        />


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

module.exports = FromProseWorkflow

_       = require 'lodash'
React   = require 'react'

ReduxMixin = require '../mixins/ReduxMixin'

normalization = require '../../shared/normalization'

store                  = require '../store'
EditableRecipePageType = require '../EditableRecipePageType'

definitions = require '../../shared/definitions'

EditableNamePage        = require './EditableNamePage'
EditableIngredientsPage = require './EditableIngredientsPage'
EditableBaseLiquorPage  = require './EditableBaseLiquorPage'
EditableTextPage        = require './EditableTextPage'
PreviewPage             = require './PreviewPage'

editableRecipeActions = require './editableRecipeActions'

# TODO: make IconButton class?
# TODO: clicking back into ingredients to edit them
# TODO: show what "type of" it is in the final display
# TODO: "oh you put numbers in" (re: instructions); "I didn't know that it would do the numbers as you go in"
# TODO: clicking on something to edit could be nice
# TODO: "done" button is rather far away

EditableRecipeView = React.createClass {
  displayName : 'EditableRecipeView'

  propTypes :
    onClose : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      editableRecipe : [ 'currentPage', 'ingredients', 'name', 'base', 'saving' ]
    }
  ]

  render : ->
    return switch @state.currentPage

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
          recipe={@_constructRecipe()}
          isSaving={@state.saving}
        />

  _makePageSwitcher : (page) ->
    return =>
      store.dispatch {
        type : 'set-editable-recipe-page'
        page
      }

  _finish : ->
    store.dispatch editableRecipeActions.saveRecipe(@_constructRecipe())
    .then =>
      @props.onClose()

  _constructRecipe : ->
    editableRecipeState = store.getState().editableRecipe

    ingredients = _.map editableRecipeState.ingredients, (ingredient) =>
      return _.pick _.extend({ tag : ingredient.tag }, ingredient.display), _.identity

    recipe = _.chain editableRecipeState
      .pick 'name', 'instructions', 'notes', 'base', 'originalRecipeId'
      .extend { ingredients, isCustom : true }
      .pick _.identity
      .value()

    return normalization.normalizeRecipe recipe
}

module.exports = EditableRecipeView

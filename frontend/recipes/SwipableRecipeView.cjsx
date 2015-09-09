_     = require 'lodash'
React = require 'react/addons'

Swipable = require '../components/Swipable'

store        = require '../store'
overlayViews = require '../overlayViews'

RecipeView = require './RecipeView'

SwipableRecipeView = React.createClass {
  displayName : 'SwipableRecipeView'

  propTypes :
    recipes : React.PropTypes.array.isRequired
    index   : React.PropTypes.number.isRequired
    onClose : React.PropTypes.func.isRequired

  getInitialState : -> {
    visibleIndex : @props.index
  }

  statics :
    showInModal : (groupedRecipes, initialIndex = 0) ->
      recipes = _.chain groupedRecipes
        .pluck 'recipes'
        .flatten()
        .value()
      store.dispatch {
        type  : 'set-recipe-viewing-index'
        index : initialIndex
      }
      overlayViews.modal.show <SwipableRecipeView
        recipes={recipes}
        index={initialIndex}
        onClose={overlayViews.modal.hide}
      />

  render : ->
    recipePages = _.map @props.recipes, (r, i) =>
      <div className='swipable-padding-wrapper' key={r.recipeId}>
        {if Math.abs(i - @state.visibleIndex) <= 1
          <div className='swipable-position-wrapper'>
            <RecipeView recipe={r} onClose={@_onClose} shareable={not r.isCustom}/>
          </div>}
      </div>

    <Swipable
      className='swipable-recipe-container'
      initialIndex={@props.index}
      onSlideChange={@_onSlideChange}
      friction=0.9
    >
      {recipePages}
    </Swipable>

  _onSlideChange : (index) ->
    @setState { visibleIndex : index }
    store.dispatch {
      type : 'set-recipe-viewing-index'
      index
    }

  _onClose : ->
    store.dispatch {
      type  : 'set-recipe-viewing-index'
      index : null
    }
    @props.onClose()
}

module.exports = SwipableRecipeView

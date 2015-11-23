_               = require 'lodash'
React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ReduxMixin        = require '../mixins/ReduxMixin'
DerivedValueMixin = require '../mixins/DerivedValueMixin'

Swipable = require '../components/Swipable'

store        = require '../store'
overlayViews = require '../overlayViews'

RecipeView = require './RecipeView'

SwipableRecipeView = React.createClass {
  displayName : 'SwipableRecipeView'

  propTypes :
    initialIndex : React.PropTypes.number.isRequired
    onClose      : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      ingredients : 'ingredientsByTag'
      ui          : 'favoritedRecipeIds'
    }
    DerivedValueMixin [
      'filteredGroupedRecipes'
      'ingredientSplitsByRecipeId'
    ]
    PureRenderMixin
  ]

  getInitialState : -> {
    visibleIndex : @props.initialIndex
  }

  statics :
    showInModal : (initialIndex = 0) ->
      store.dispatch {
        type  : 'set-recipe-viewing-index'
        index : initialIndex
      }

      overlayViews.modal.show <SwipableRecipeView
        initialIndex={initialIndex}
        onClose={overlayViews.modal.hide}
      />

  render : ->
    recipes = _.chain @state.filteredGroupedRecipes
      .pluck 'recipes'
      .flatten()
      .value()

    recipePages = _.map recipes, (r, i) =>
      <div className='swipable-padding-wrapper' key={r.recipeId}>
        {if Math.abs(i - @state.visibleIndex) <= 1
          <div className='swipable-position-wrapper'>
            <RecipeView
              recipe={r}
              ingredientsByTag={@state.ingredientsByTag}
              ingredientSplits={@state.ingredientSplitsByRecipeId?[r.recipeId]}
              onClose={@_onClose}
              onFavorite={@_onFavorite}
              isFavorited={r.recipeId in @state.favoritedRecipeIds}
              isShareable={not r.isCustom}
            />
          </div>}
      </div>

    <Swipable
      className='swipable-recipe-container'
      initialIndex={@props.initialIndex}
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

  _onFavorite : (recipe, shouldFavorite) ->
    if shouldFavorite
      store.dispatch {
        type     : 'favorite-recipe'
        recipeId : recipe.recipeId
      }
    else
      store.dispatch {
        type     : 'unfavorite-recipe'
        recipeId : recipe.recipeId
      }
}

module.exports = SwipableRecipeView

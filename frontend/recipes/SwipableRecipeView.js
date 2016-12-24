_               = require 'lodash'
React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ReduxMixin        = require '../mixins/ReduxMixin'
DerivedValueMixin = require '../mixins/DerivedValueMixin'

Swipable = require '../components/Swipable'

store = require '../store'

RecipeView = require './RecipeView'

SwipableRecipeView = React.createClass {
  displayName : 'SwipableRecipeView'

  propTypes :
    onClose : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      recipes     : 'recipesById'
      ingredients : 'ingredientsByTag'
      ui          : [ 'favoritedRecipeIds', 'currentlyViewedRecipeIds', 'recipeViewingIndex' ]
    }
    DerivedValueMixin [
      'ingredientSplitsByRecipeId'
    ]
    PureRenderMixin
  ]

  render : ->
    if @state.currentlyViewedRecipeIds.length == 0
      return React.createElement("div", null)
    else
      recipePages = _.map @state.currentlyViewedRecipeIds, (recipeId, i) =>
        React.createElement("div", {"className": 'swipable-padding-wrapper', "key": (recipeId)},
          (if Math.abs(i - @state.recipeViewingIndex) <= 1 then @_renderRecipe(@state.recipesById[recipeId]))
        )

      return React.createElement(Swipable, { \
        "className": 'swipable-recipe-container',  \
        "initialIndex": (@state.recipeViewingIndex),  \
        "onSlideChange": (@_onSlideChange),  \
        "friction": 0.9
      },
        (recipePages)
      )

  _renderRecipe : (recipe) ->
    return React.createElement("div", {"className": 'swipable-position-wrapper'},
      React.createElement(RecipeView, { \
        "recipe": (recipe),  \
        "ingredientsByTag": (@state.ingredientsByTag),  \
        "ingredientSplits": (@state.ingredientSplitsByRecipeId?[recipeId]),  \
        "onClose": (@_onClose),  \
        "onFavorite": (@_onFavorite),  \
        "onEdit": (if recipe.isCustom then @_onEdit),  \
        "isFavorited": (recipeId in @state.favoritedRecipeIds),  \
        "isShareable": (true)
      })
    )

  _onSlideChange : (index) ->
    store.dispatch {
      type : 'set-recipe-viewing-index'
      index
    }

  _onClose : ->
    store.dispatch {
      type  : 'set-recipe-viewing-index'
      index : 0
    }

    @props.onClose()

  _onEdit : (recipe) ->
    store.dispatch {
      type : 'seed-recipe-editor'
      recipe
    }

    store.dispatch {
      type : 'show-recipe-editor'
    }

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

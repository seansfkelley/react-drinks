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
    recipeIds : React.PropTypes.array.isRequired
    index     : React.PropTypes.number.isRequired
    onClose   : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      recipes     : 'recipesById'
      ingredients : 'ingredientsByTag'
      ui          : 'favoritedRecipeIds'
    }
    DerivedValueMixin [
      'ingredientSplitsByRecipeId'
    ]
    PureRenderMixin
  ]

  render : ->
    if @props.recipeIds.length == 0
      return <div/>
    else
      recipePages = _.map @props.recipeIds, (recipeId, i) =>
        <div className='swipable-padding-wrapper' key={recipeId}>
          {if Math.abs(i - @props.index) <= 1
            recipe = @state.recipesById[recipeId]
            <div className='swipable-position-wrapper'>
              <RecipeView
                recipe={recipe}
                ingredientsByTag={@state.ingredientsByTag}
                ingredientSplits={@state.ingredientSplitsByRecipeId?[recipeId]}
                onClose={@_onClose}
                onFavorite={@_onFavorite}
                isFavorited={recipeId in @state.favoritedRecipeIds}
                isShareable={not recipe.isCustom}
              />
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

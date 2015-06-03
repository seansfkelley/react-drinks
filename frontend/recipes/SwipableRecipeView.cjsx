_     = require 'lodash'
React = require 'react/addons'

Swipable = require '../components/Swipable'

AppDispatcher = require '../AppDispatcher'

RecipeView = require './RecipeView'

SwipableRecipeView = React.createClass {
  displayName : 'SwipableRecipeView'

  propTypes :
    recipes : React.PropTypes.array.isRequired
    index   : React.PropTypes.number.isRequired

  getInitialState : -> {
    visibleIndex : @props.index
  }

  render : ->
    recipePages = _.map @props.recipes, (r, i) =>
      <div className='swipable-padding-wrapper' key={r.recipeId}>
        {if Math.abs(i - @state.visibleIndex) <= 1
          <div className='swipable-position-wrapper'>
            <RecipeView recipe={r} onClose={@_closeModal}/>
          </div>}
      </div>

    <Swipable
      className='swipable-recipe-container'
      initialIndex={@props.index}
      onSlideChange={@_onSlideChange}
      friction=0.95
    >
      {recipePages}
    </Swipable>

  _onSlideChange : (index) ->
    @setState { visibleIndex : index }

  _closeModal : ->
    AppDispatcher.dispatch {
      type : 'hide-modal'
    }
}

module.exports = SwipableRecipeView

# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'
Swipe = require 'react-swipe'

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
      <div className='swipable-wrapper' key={r.normalizedName}>
        {if Math.abs(i - @state.visibleIndex) <= 1 then <RecipeView recipe={r}/>}
      </div>

    # We can trick the swipe into not using the full width, but is there any way to make
    # it not hide everything that's not the current slide so we can see the edges?
    <Swipe continuous=false startSlide={@props.index} callback={@_onSwipe} ref='swipe'>
      {recipePages}
    </Swipe>

  _onSwipe : (index) ->
    @setState { visibleIndex : index }
}

module.exports = SwipableRecipeView

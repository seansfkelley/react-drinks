# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'
Swipe = require 'react-swipe'

RecipeView = require './RecipeView'

SwipableRecipeView = React.createClass {
  render : ->
    recipePages = _.map @props.recipes, (r) ->
      <div className='swipable-wrapper' key={r.normalizedName}>
        <RecipeView recipe={r}/>
      </div>
    # We can trick the swipe into not using the full width, but is there any way to make
    # it not hide everything that's not the current slide so we can see the edges?
    <Swipe continuous=false startSlide={@props.index}>
      {recipePages}
    </Swipe>
}

module.exports = SwipableRecipeView

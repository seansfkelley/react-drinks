# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

AppDispatcher = require './AppDispatcher'

IngredientView = React.createClass {
  render: ->
    className = 'ingredient'
    if @props.isSubstitute
      className += ' substitute'
    else if @props.isMissing
      className += ' missing'
    <div className={className}>
      <div className='name'>{@props.name}</div>
    </div>
}

RecipeView = React.createClass {
  render: ->
    ingredientNodes = _.map @props.recipe.ingredients, (i) =>
      isMissing    = i.tag in (@props.recipe.missing ? [])
      isSubstitute = i.tag in (@props.recipe.substitute ? [])
      return <IngredientView isMissing={isMissing} isSubstitute={isSubstitute} name={i.display} key={i.tag}/>

    <div className='recipe' onTouchTap={@_closeRecipe}>
      <div className='name'>{@props.recipe.name}</div>
      {ingredientNodes}
    </div>

  _closeRecipe : ->
    AppDispatcher.dispatch {
      type : 'close-recipe'
    }
}

module.exports = RecipeView

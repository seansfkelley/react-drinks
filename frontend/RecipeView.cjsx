# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

AppDispatcher = require './AppDispatcher'

SectionHeader = React.createClass {
  render : ->
    <div className='ingredient-section-header'>{@props.text}</div>
}

IngredientView = React.createClass {
  render : ->
    <div className={'measured-ingredient ' + @props.category}>
      <div className='name'>{@props.measuredIngredient.displayMeasure} {@props.measuredIngredient.displayIngredient}</div>
    </div>
}

IngredientCategory =
  MISSING    : 'missing'
  SUBSTITUTE : 'substitute'
  AVAILABLE  : 'available'

HUMAN_READABLE_CATEGORY_TITLE =
  missing    : 'Missing Ingredients'
  substitute : 'Substituted Ingredients'
  available  : 'Ingredients'

RecipeView = React.createClass {
  render : ->
    if @props.recipe.missing? # TODO: We're reusing this view for both types of recipes; seems bad.
      ingredientNodes = _.chain IngredientCategory
        .invert()
        .mapValues (_, key) => @props.recipe[key]
        .map (measuredIngredients, category) =>
          this
          if measuredIngredients.length == 0
            return []
          else
            return [
              <SectionHeader text={HUMAN_READABLE_CATEGORY_TITLE[category]} key={'header-' + category}/>
              _.map measuredIngredients, (i) -> <IngredientView category={category} measuredIngredient={i} key={i.tag}/>
            ]
        .flatten()
        .value()
    else
      ingredientNodes = [
        <SectionHeader text={HUMAN_READABLE_CATEGORY_TITLE.available} key={'header-' + IngredientCategory.available}/>
      ].concat _.map @props.recipe.ingredients, (i) ->
        <IngredientView category={IngredientCategory.available} measuredIngredient={i} key={i.tag}/>

    if @props.recipe.notes?
      recipeNotes =
        <div className='recipe-notes'>
          <div className='header'>Notes</div>
          <div className='text'>{@props.recipe.instructions}</div>
        </div>

    <div className='recipe-view sticky-header-container'>
      <div className='recipe-title sticky-header-bar'>
        <span className='name'>{@props.recipe.name}</span>
        <i className='fa fa-times' onTouchTap={@_closeRecipe}/>
      </div>
      <div className='recipe-description sticky-header-content-pane'>
        <div className='recipe-ingredients'>
          {ingredientNodes}
        </div>
        <div className='recipe-instructions'>
          <div className='header'>Instructions</div>
          <div className='text'>{@props.recipe.instructions}</div>
        </div>
        {recipeNotes}
      </div>
    </div>

  _closeRecipe : ->
    AppDispatcher.dispatch {
      type : 'close-recipe'
    }
}

module.exports = RecipeView

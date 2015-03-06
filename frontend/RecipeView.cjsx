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
  missing    : 'You\'re Missing'
  substitute : 'You Can Substitute'
  available  : 'You Have'

RecipeView = React.createClass {
  render : ->
    if @props.recipe.missing? # TODO: We're reusing this view for both types of recipes; seems bad.
      ingredientNodes = _.chain IngredientCategory
        .invert()
        .mapValues (_, key) => @props.recipe[key]
        # TODO: The order these sections end up in is arbitrary; we should enforce it.
        .map (measuredIngredients, category) =>
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
        <SectionHeader text='Ingredients' key={'header-' + IngredientCategory.available}/>
      ].concat _.map @props.recipe.ingredients, (i) ->
        <IngredientView category={IngredientCategory.available} measuredIngredient={i} key={i.tag}/>

    if @props.recipe.notes?
      recipeNotes =
        <div className='recipe-notes'>
          <div className='header'>Notes</div>
          <div className='text'>{@props.recipe.notes}</div>
        </div>

    <div className='recipe-view fixed-header-container'>
      <div className='recipe-title fixed-header-bar'>
        <span className='name'>{@props.recipe.name}</span>
        <i className='fa fa-times' onTouchTap={@_closeRecipe}/>
      </div>
      <div className='recipe-description fixed-content-pane'>
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

  _closeRecipe : (e) ->
    # TODO: Deferring fixes the issue where we replace the body and the event is then handled by the
    # new view that ends up there, which it should not be.
    _.defer ->
      AppDispatcher.dispatch {
        type : 'close-recipe'
      }
}

module.exports = RecipeView

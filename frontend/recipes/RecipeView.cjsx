_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'
{ PureRenderMixin } = React.addons

FluxMixin = require '../mixins/FluxMixin'

FixedHeaderFooter = require '../components/FixedHeaderFooter'
TitleBar          = require '../components/TitleBar'

AppDispatcher = require '../AppDispatcher'
utils         = require '../utils'
{ UiStore }   = require '../stores'

IngredientCategory =
  MISSING    : 'missing'
  SUBSTITUTE : 'substitute'
  AVAILABLE  : 'available'

IngredientView = React.createClass {
  displayName : 'IngredientView'

  mixins : [ PureRenderMixin ]

  propTypes :
    displayAmount      : React.PropTypes.string
    displayUnit        : React.PropTypes.string
    displayIngredient  : React.PropTypes.string.isRequired
    displaySubstitutes : React.PropTypes.array

  getDefaultProps : -> {
    displaySubstitutes : []
  }

  render : ->
    amount = utils.fractionify(@props.displayAmount ? '')
    unit = @props.displayUnit ? ''
    # The space is necessary to space out the spans from each other. Newlines are insufficient.
    # Include the keys only to keep React happy so that it warns us about significant uses of
    # arrays without key props.
    <div className={classnames 'measured-ingredient', @props.className}>
      <span className='measure'>
        <span className='amount'>{amount}</span>
        {' '}
        <span className='unit'>{unit}</span>
      </span>
      <span className='ingredient'>{@props.displayIngredient}</span>
      {if @props.displaySubstitutes.length
        [
          <br key='br'/>
          <span className='substitute-label' key='label'>try:</span>
          <span className='substitute-content' key='content'>{@props.displaySubstitutes}</span>
        ]
      }
    </div>
}

RecipeView = React.createClass {
  displayName : 'RecipeView'

  mixins : [ PureRenderMixin ]

  propTypes :
    recipe : React.PropTypes.object.isRequired

  render : ->
    # TODO: We're reusing this view for both types of recipes; seems bad.
    if @props.recipe.missing? and (@props.recipe.missing.length > 0 or @props.recipe.substitute.length > 0)
      ingredientNodes = _.chain IngredientCategory
        .invert()
        .mapValues (_, key) => @props.recipe[key]
        # TODO: The order these sections end up in is arbitrary; we should enforce it.
        .map @_renderCategory
        .flatten()
        .value()
    else
      ingredientNodes = _.map @props.recipe.ingredients, (i) ->
        <IngredientView {...i} key={i.tag ? i.displayIngredient}/>

    if @props.recipe.notes?
      recipeNotes =
        <div className='recipe-notes'>
          <div className='text'>
            {utils.fractionify @props.recipe.notes}
          </div>
        </div>

    instructionLines = _.chain @props.recipe.instructions.split('\n')
      .compact()
      .map (l, i) -> <li className='text-line' key={i}>{utils.fractionify l}</li>
      .value()
    recipeInstructions = <ol className='recipe-instructions'>{instructionLines}</ol>

    header = <TitleBar rightIcon='fa-times' rightIconOnTouchTap={@_closeModal}>
      {@props.recipe.name}
    </TitleBar>

    <FixedHeaderFooter
      className='default-modal recipe-view'
      header={header}
    >
      <div className='recipe-description'>
        <div className='recipe-ingredients'>
          {ingredientNodes}
        </div>
        {recipeInstructions}
        {recipeNotes}
      </div>
    </FixedHeaderFooter>

  _renderCategory : (measuredIngredients, category) ->
    if measuredIngredients.length == 0
      return []
    else
      if category == IngredientCategory.SUBSTITUTE
        measuredIngredients = _.map measuredIngredients, (i) ->
          if i.have.length > 1
            displaySubstitute = "#{_.initial(i.have).join(', ')} or #{_.last(i.have)}"
          else
            displaySubstitute = i.have[0]
          return _.defaults {
            className          : 'substituted'
            displaySubstitutes : i.have
          }, i.need
      else if category == IngredientCategory.MISSING
        measuredIngredients = _.map measuredIngredients, (i) ->
          return _.defaults { className : 'missing' }, i

      return _.map measuredIngredients, (i) -> <IngredientView {...i} key={i.tag ? i.displayIngredient}/>

  _closeModal : ->
    AppDispatcher.dispatch {
      type : 'hide-modal'
    }
}

module.exports = RecipeView

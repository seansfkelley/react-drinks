_          = require 'lodash'
React      = require 'react/addons'
{ PureRenderMixin } = React.addons

utils       = require '../utils'
definitions = require '../../shared/definitions'

ReduxMixin = require '../mixins/ReduxMixin'

FixedHeaderFooter = require '../components/FixedHeaderFooter'
TitleBar          = require '../components/TitleBar'

MeasuredIngredient = require './MeasuredIngredient'

IS_IPHONE_IOS_8 = window.navigator.userAgent.indexOf('iPhone OS 8') != -1

IngredientCategory = {
  MISSING    : 'missing'
  SUBSTITUTE : 'substitute'
  AVAILABLE  : 'available'
}

RecipeView = React.createClass {
  displayName : 'RecipeView'

  mixins : [ PureRenderMixin ]

  propTypes :
    recipe           : React.PropTypes.object.isRequired
    ingredientSplits : React.PropTypes.object
    ingredientsByTag : React.PropTypes.object
    onClose          : React.PropTypes.func
    shareable        : React.PropTypes.bool

  getDefaultProps : ->
    return {
      shareable : false
    }

  render : ->
    if @props.ingredientSplits?
      ingredientNodes = _.chain IngredientCategory
        .invert()
        .mapValues (_, key) => @props.ingredientSplits[key]
        # TODO: The order these sections end up in is arbitrary; we should enforce it.
        .map @_renderCategory
        .flatten()
        .value()
    else
      ingredientNodes = _.map @props.recipe.ingredients, (i) ->
        # This fucked-up key is because sometimes, the same tag will appear twice (e.g. Penicillin's two scotches).
        <MeasuredIngredient {...i} key={"#{i.tag} #{i.displayIngredient}"}/>

    if @props.recipe.notes?
      recipeNotes =
        <div className='recipe-notes'>
          <div className='text'>
            {utils.fractionify @props.recipe.notes}
          </div>
        </div>

    if @props.recipe.source? and @props.recipe.url?
      recipeUrl = <a className='recipe-url' href={@props.recipe.url} target='_blank'>
        <span className='lead-in'>source:</span>
        {@props.recipe.source}
        <i className='fa fa-external-link'/>
      </a>

    instructionLines = _.chain @props.recipe.instructions.split('\n')
      .compact()
      .map (l, i) -> <li className='text-line' key={i}>{utils.fractionify l}</li>
      .value()
    recipeInstructions = <ol className='recipe-instructions'>{instructionLines}</ol>

    if @props.shareable and IS_IPHONE_IOS_8
      shareButtonProps = {
        leftIcon           : 'fa-share-square-o'
        leftIconOnTouchTap : => window.open "sms:&body=#{@props.recipe.name} #{definitions.BASE_URL}/recipe/#{@props.recipe.recipeId}"
      }

    if @props.onClose?
      header = <TitleBar rightIcon='fa-times' rightIconOnTouchTap={@props.onClose} {...shareButtonProps}>
        {@props.recipe.name}
      </TitleBar>
    else
      header = <TitleBar {...shareButtonProps}>{@props.recipe.name}</TitleBar>

    <FixedHeaderFooter
      className='recipe-view'
      header={header}
    >
      <div className='recipe-description'>
        <div className='recipe-ingredients'>
          {ingredientNodes}
        </div>
        {recipeInstructions}
        {recipeNotes}
        {recipeUrl}
      </div>
    </FixedHeaderFooter>

  _renderCategory : (measuredIngredients, category) ->
    if measuredIngredients.length == 0
      return []
    else
      if category == IngredientCategory.SUBSTITUTE
        measuredIngredients = _.map measuredIngredients, (i) ->
          return _.defaults {
            isSubstituted      : true
            displaySubstitutes : i.have
          }, i.need
      else if category == IngredientCategory.MISSING
        measuredIngredients = _.map measuredIngredients, (i) =>
          return _.defaults {
            isMissing  : true
            difficulty : @props.ingredientsByTag[i.tag].difficulty
          }, i

      return _.map measuredIngredients, (i) -> <MeasuredIngredient {...i} key={"#{i.tag} #{i.displayIngredient}"}/>
}

module.exports = RecipeView

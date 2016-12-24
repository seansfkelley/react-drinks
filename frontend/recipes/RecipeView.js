_               = require 'lodash'
React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'
classnames      = require 'classnames'

utils       = require '../utils'
definitions = require '../../shared/definitions'

ReduxMixin = require '../mixins/ReduxMixin'

TitleBar = require '../components/TitleBar'

MeasuredIngredient = require './MeasuredIngredient'

IS_IPHONE_IOS_8 = window.navigator.userAgent.indexOf('iPhone OS 8') != -1

IngredientCategory = {
  MISSING    : 'missing'
  SUBSTITUTE : 'substitute'
  AVAILABLE  : 'available'
}

IconButton = ({ icon, text, onTouchTap }) ->
  React.createElement("div", {"className": 'icon-button', "onTouchTap": (onTouchTap)},
    React.createElement("i", {"className": (classnames 'fa', icon)}),
    React.createElement("div", {"className": 'label'}, (text))
  )

IconButton.propTypes = {
  icon       : React.PropTypes.string
  text       : React.PropTypes.string
  onTouchTap : React.PropTypes.func
}

RecipeView = React.createClass {
  displayName : 'RecipeView'

  mixins : [ PureRenderMixin ]

  propTypes :
    recipe           : React.PropTypes.object.isRequired
    ingredientSplits : React.PropTypes.object
    ingredientsByTag : React.PropTypes.object
    onClose          : React.PropTypes.func
    onFavorite       : React.PropTypes.func
    onEdit           : React.PropTypes.func
    isFavorited      : React.PropTypes.bool
    isShareable      : React.PropTypes.bool

  getDefaultProps : ->
    return {
      isShareable : false
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
        React.createElement(MeasuredIngredient, Object.assign({},  i, {"key": ("#{i.tag} #{i.displayIngredient}")}))

    if @props.recipe.notes?
      recipeNotes =
        React.createElement("div", {"className": 'recipe-notes'},
          React.createElement("div", {"className": 'text'},
            (utils.fractionify @props.recipe.notes)
          )
        )

    if @props.recipe.source? and @props.recipe.url?
      recipeUrl = React.createElement("a", {"className": 'recipe-url', "href": (@props.recipe.url), "target": '_blank'},
        React.createElement("span", {"className": 'lead-in'}, "source:"),
        (@props.recipe.source),
        React.createElement("i", {"className": 'fa fa-external-link'})
      )

    instructionLines = _.chain @props.recipe.instructions.split('\n')
      .compact()
      .map (l, i) -> React.createElement("li", {"className": 'text-line', "key": (i)}, (utils.fractionify l))
      .value()
    recipeInstructions = React.createElement("ol", {"className": 'recipe-instructions'}, (instructionLines))

    if @props.onClose?
      header = React.createElement(TitleBar, {"className": 'fixed-header', "rightIcon": 'fa-times', "rightIconOnTouchTap": (@props.onClose)},
        (@props.recipe.name)
      )
    else
      header = React.createElement(TitleBar, {"className": 'fixed-header'}, (@props.recipe.name))

    footerButtons = []

    if @props.onEdit
      footerButtons.push React.createElement(IconButton, { \
        "key": 'edit',  \
        "icon": 'fa-pencil-square-o',  \
        "text": 'Edit',  \
        "onTouchTap": (@_edit)
      })
    if @props.isShareable
      footerButtons.push React.createElement(IconButton, { \
        "key": 'share',  \
        "icon": 'fa-share-square-o',  \
        "text": 'Share',  \
        "onTouchTap": (@_share)
      })
    if @props.onFavorite
      footerButtons.push React.createElement(IconButton, { \
        "key": 'favorite',  \
        "icon": (classnames { 'fa-star' : @props.isFavorited, 'fa-star-o' : not @props.isFavorited }),  \
        "text": 'Favorite',  \
        "onTouchTap": (@_favorite)
      })

    React.createElement("div", {"className": 'recipe-view fixed-header-footer'},
      (header),
      React.createElement("div", {"className": 'recipe-description fixed-content-pane'},
        React.createElement("div", {"className": 'recipe-ingredients'},
          (ingredientNodes)
        ),
        (recipeInstructions),
        (recipeNotes),
        (recipeUrl)
      ),
      (if footerButtons.length then React.createElement("div", {"className": 'fixed-footer'}, (footerButtons)))
    )

  _edit : ->
    @props.onEdit @props.recipe

  _share : ->
    window.open "sms:&body=#{@props.recipe.name} #{definitions.BASE_URL}/recipe/#{@props.recipe.recipeId}"

  _favorite : ->
    @props.onFavorite @props.recipe, not @props.isFavorited

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

      return _.map measuredIngredients, (i) -> React.createElement(MeasuredIngredient, Object.assign({},  i, {"key": ("#{i.tag} #{i.displayIngredient}")}))
}

module.exports = RecipeView

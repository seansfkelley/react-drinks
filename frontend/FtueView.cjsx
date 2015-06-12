_     = require 'lodash'
React = require 'react/addons'
{ PureRenderMixin } = React.addons

FluxMixin = require './mixins/FluxMixin'

List              = require './components/List'
TitleBar          = require './components/TitleBar'
FixedHeaderFooter = require './components/FixedHeaderFooter'

AppDispatcher       = require './AppDispatcher'
{ IngredientStore } = require './stores'

isMobileSafari = ->
  return window.navigator.userAgent.indexOf('iPhone') != -1 and window.navigator.userAgent.indexOf('CriOS') == -1

isWebClip = ->
  return !!window.navigator.standalone

# TODO: Three-part list:
#  1. Web clip notification, if appropriate.
#  2. Brief explanation of premise: mixability, substitutions.
#  3. Ingredient selection (now that it's been explained why this is important).

# This is kind of a clone of the default ingredient selection view.
FtueView = React.createClass {
  displayName : 'FtueView'

  mixins : [ PureRenderMixin ]

  propTypes :
    alphabeticalIngredients       : React.PropTypes.array.isRequired
    initialSelectedIngredientTags : React.PropTypes.object.isRequired
    onComplete                    : React.PropTypes.func.isRequired

  getInitialState : -> {
    selectedIngredientTags : _.clone @props.initialSelectedIngredientTags
  }

  render : ->
    header = <div>
      <TitleBar>Welcome!</TitleBar>
      <div className='explanation'>
        To get things started, select all the ingredients you have in your bar at the moment:
      </div>
    </div>

    <FixedHeaderFooter
      className='ftue-view'
      header={header}
      footer={<TitleBar onTouchTap={@_finish}>Continue</TitleBar>}
    >
      <List>
        {for ingredient in @props.alphabeticalIngredients
          <List.Item key={ingredient.tag} onTouchTap={@_ingredientSelector ingredient.tag}>
            <span className='name'>{ingredient.display}</span>
            {if @state.selectedIngredientTags[ingredient.tag]
              <i className='fa fa-check-circle'/>}
          </List.Item>}
      </List>
    </FixedHeaderFooter>

  _ingredientSelector : (tag) ->
    return =>
      # It is VERY IMPORTANT that these create a new instance: this is how PureRenderMixin guarantees correctness.
      if @state.selectedIngredientTags[tag]?
        selectedIngredientTags = _.omit @state.selectedIngredientTags, tag
      else
        selectedIngredientTags = _.clone @state.selectedIngredientTags
        selectedIngredientTags[tag] = true
      @setState { selectedIngredientTags }

  _finish : ->
    AppDispatcher.dispatch {
      type                   : 'set-selected-ingredient-tags'
      selectedIngredientTags : @state.selectedIngredientTags
    }
    @props.onComplete()
}

module.exports = FtueView

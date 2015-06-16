_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

{ PureRenderMixin } = React.addons

FluxMixin = require './mixins/FluxMixin'

List              = require './components/List'
TitleBar          = require './components/TitleBar'
FixedHeaderFooter = require './components/FixedHeaderFooter'

# TODO:
#  - Make a mention of the the ingredients button and add-recipe button
#  - Add progress indicator dots at the bottom?

MeasuredIngredient = require './recipes/MeasuredIngredient'
MixabilityToggle   = require './recipes/MixabilityToggle'
RecipeListItem     = require './recipes/RecipeListItem'

AppDispatcher       = require './AppDispatcher'
{ IngredientStore } = require './stores'

isMobileSafari = ->
  return window.navigator.userAgent.indexOf('iPhone') != -1 and window.navigator.userAgent.indexOf('CriOS') == -1

isWebClip = ->
  return !!window.navigator.standalone


WelcomePage = React.createClass {
  displayName : 'WelcomePage'

  mixins : [ PureRenderMixin ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  getInitialState : -> {
    isMobileSafari : isMobileSafari()
    isWebClip      : isWebClip()
  }

  render : ->
    if @state.isMobileSafari
      webClipNotification = [
        <h3 key='protip'>Protip!</h3>
        <p className='explanation' key='explanation'>
          If you want quicker access, you can tap <img src='/img/ios-export.png'/> at the bottom of the screen to save this to the home screen.
        </p>
      ]
    else if not @state.isWebClip
      webClipNotification = [
        <h3 key='protip'>Protip:</h3>
        <p className='explanation' key='explanation'>
          You can save this to your home screen through Safari for quicker access.
          In Safari, tap <img src='/img/ios-export.png'/> at the bottom of the screen, then save to home screen.
        </p>
      ]

    <FixedHeaderFooter
      className='ftue-page web-clip-page'
      header={<TitleBar>Spirit Guide</TitleBar>}
      footer={<TitleBar onTouchTap={@props.onComplete}>Continue</TitleBar>}
    >
      <h3>Welcome!</h3>
      <p>
        Spirit Guide figures out what cocktails you can make based on what's in your liquor cabinet.
      </p>
      {webClipNotification}
    </FixedHeaderFooter>
}

DUMMY_INGREDIENTS = [
  'Gin'
  'Vodka'
  'Whiskey'
  'Rum'
  'Tequila'
]

SampleIngredientPage = React.createClass {
  displayName : 'SampleIngredientPage'

  mixins : [ PureRenderMixin ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  getInitialState : -> {
    selectedIngredients : []
  }

  render : ->
    <FixedHeaderFooter
      className='ftue-page sample-ingredient-page explanation-page'
      header={<TitleBar>Spirit Guide</TitleBar>}
      footer={<TitleBar onTouchTap={@props.onComplete}>Continue</TitleBar>}
    >
      <h3>You Liquor Cabinet</h3>
      <p>
        There's a list of ingredients you can pick from. Tap an ingredient to indicate you have it.
      </p>

      <List>
        {_.map DUMMY_INGREDIENTS, (i) =>
          return <List.Item onTouchTap={_.partial @_toggle, i} key={i}>
            {i}
            {if i in @state.selectedIngredients
              <i className='fa fa-check-circle'/>
            }
          </List.Item>}
      </List>
    </FixedHeaderFooter>

  _toggle : (i) ->
    if i in @state.selectedIngredients
      @setState { selectedIngredients : _.without @state.selectedIngredients, i }
    else
      @setState { selectedIngredients : [ i ].concat(@state.selectedIngredients) }
}


DUMMY_RECIPES = [
  recipeName : 'Aviation'
  mixability : 2
,
  recipeName : 'Gin & Tonic'
  mixability : 0
,
  recipeName : 'Margarita'
  mixability : 3
,
  recipeName : 'Whiskey Sour'
  mixability : 1
]

_getFilteredDummyRecipes = (mixabilityToggles) ->
  allow = []
  if mixabilityToggles.mixable
    allow.push 0
  if mixabilityToggles.nearMixable
    allow.push 1
  if mixabilityToggles.notReallyMixable
    allow.push [2, 3]...
  return _.filter DUMMY_RECIPES, ({ mixability }) -> mixability in allow

SubstitionPage = React.createClass {
  displayName : 'SubstitionPage'

  mixins : [ PureRenderMixin ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  render : ->
    <FixedHeaderFooter
      className='ftue-page explanation-page'
      header={<TitleBar>Spirit Guide</TitleBar>}
      footer={<TitleBar onTouchTap={@props.onComplete}>Continue</TitleBar>}
    >
      <h3>Substitutions</h3>

      <p>
        If a recipe calls for an ingredient that you don't have but can substitute for, that recipe
        will still show up in the results.
      </p>
      <p>
        Substituted ingredients look like this:
      </p>

      <MeasuredIngredient
        displayAmount='1'
        displayUnit='oz'
        displayIngredient='rye whiskey'
        displaySubstitutes={[ 'bourbon' ]}
        isSubstituted=true
      />
    </FixedHeaderFooter>
}

MixabilityPage = React.createClass {
  displayName : 'MixabilityPage'

  mixins : [ PureRenderMixin ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  getInitialState : -> {
    mixabilityToggles :
      mixable          : true
      nearMixable      : true
      notReallyMixable : true
  }

  render : ->
    dummyRecipeNodes = _.map _getFilteredDummyRecipes(@state.mixabilityToggles), (props) ->
      return <RecipeListItem key={props.recipeName} {...props}/>

     <FixedHeaderFooter
       className='ftue-page explanation-page'
       header={<TitleBar>Spirit Guide</TitleBar>}
       footer={<TitleBar onTouchTap={@props.onComplete}>Continue</TitleBar>}
     >
      <h3>Mixability</h3>
      <p>
        If you're willing to take a trip to the corner store, you can make the search bring up recipes that
        are missing one or more ingredients, too.
      </p>
      <p>
        Try tapping these:
      </p>

      <MixabilityToggle
        mixabilityToggles={@state.mixabilityToggles}
        onToggle={@_onMixabilityToggle}
      />

      <p>
        And you'll see more or fewer recipes:
      </p>

      <List>
        {dummyRecipeNodes}
      </List>
    </FixedHeaderFooter>

  _onMixabilityToggle : (setting) ->
    @state.mixabilityToggles[setting] = not @state.mixabilityToggles[setting]
    @setState { mixabilityToggles : _.clone @state.mixabilityToggles }
}


# This is kind of a clone of the default ingredient selection view.
IngredientsPage = React.createClass {
  displayName : 'IngredientsPage'

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
      <TitleBar>Spirit Guide</TitleBar>
      <p className='sub-header'>
        To get things started, select all the ingredients you have in your bar at the moment:
      </p>
    </div>

    <FixedHeaderFooter
      className='ftue-page ingredients-page'
      header={header}
      footer={<TitleBar onTouchTap={@_finish}>Finish</TitleBar>}
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

ORDERED_PAGE_CLASSES = [
  WelcomePage
  SampleIngredientPage
  SubstitionPage
  MixabilityPage
  IngredientsPage
]

FtueView = React.createClass {
  displayName : 'FtueView'

  mixins : [ PureRenderMixin ]

  propTypes :
    alphabeticalIngredients       : React.PropTypes.array.isRequired
    initialSelectedIngredientTags : React.PropTypes.object.isRequired
    onComplete                    : React.PropTypes.func.isRequired

  getInitialState : -> {
    currentPageIndex : 0
  }

  render : ->
    PageClass = ORDERED_PAGE_CLASSES[@state.currentPageIndex]
    if @state.currentPageIndex == ORDERED_PAGE_CLASSES.length - 1
      onComplete = @props.onComplete
    else
      onComplete = _.partial @_goToPage, @state.currentPageIndex + 1
    return <PageClass {...@props} onComplete={onComplete}/>

  _goToPage : (currentPageIndex) ->
    @setState { currentPageIndex }
}

module.exports = FtueView

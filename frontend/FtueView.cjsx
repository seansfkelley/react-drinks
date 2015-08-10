_          = require 'lodash'
React      = require 'react/addons'
Isvg       = require 'react-inlinesvg'
classnames = require 'classnames'

{ PureRenderMixin } = React.addons

FluxMixin = require './mixins/FluxMixin'

List              = require './components/List'
TitleBar          = require './components/TitleBar'
FixedHeaderFooter = require './components/FixedHeaderFooter'

# TODO:
#  - Make a mention of the the ingredients button and add-recipe button
#  - Add progress indicator dots at the bottom?

MeasuredIngredient    = require './recipes/MeasuredIngredient'
MixabilityToggle      = require './recipes/MixabilityToggle'
RecipeListItem        = require './recipes/RecipeListItem'
GroupedIngredientList = require './ingredients/GroupedIngredientList'

AppDispatcher = require './AppDispatcher'

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
          If you want quicker access to Spirit Guide, you can tap <img src='/assets/img/ios-export.png'/> at the bottom of the screen to save it to the home screen.
        </p>
      ]
    else if not @state.isWebClip
      webClipNotification = [
        <h3 key='protip'>Protip:</h3>
        <p className='explanation' key='explanation'>
          You can save this to your home screen through Safari for quicker access.
          In Safari, tap <img src='/assets/img/ios-export.png'/> at the bottom of the screen, then save to home screen.
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

SAMPLE_INGREDIENT_TAGS = [
  'gin'
  'genever'
  'bourbon'
  'rye whiskey'
  'blanco tequila'
  'anejo tequila'
  'white rum'
  'dark rum'
  'vodka'
  'bison grass vodka'
]

SampleIngredientPage = React.createClass {
  displayName : 'SampleIngredientPage'

  mixins : [ PureRenderMixin ]

  propTypes :
    groupedIngredients : React.PropTypes.array.isRequired
    onComplete         : React.PropTypes.func.isRequired

  getInitialState : ->
    sampleGroupedIngredients = _.chain @props.groupedIngredients
      .map ({ name, ingredients }) ->
        return {
          name
          ingredients : _.filter ingredients, (i) -> i.tag in SAMPLE_INGREDIENT_TAGS
        }
      .filter ({ ingredients }) -> ingredients.length > 0
      .value()
    return { sampleGroupedIngredients }

  render : ->
    <FixedHeaderFooter
      className='ftue-page sample-ingredient-page explanation-page'
      header={<TitleBar>Spirit Guide</TitleBar>}
      footer={<TitleBar onTouchTap={@_onComplete}>Continue</TitleBar>}
    >
      <h3>Your Liquor Cabinet</h3>
      <p>
        Here's a sample list of ingredients you can pick from. You'll be able to edit this list later.
      </p>

      <GroupedIngredientList
        groupedIngredients={@state.sampleGroupedIngredients}
        initialSelectedIngredientTags={{}}
        ref='ingredientList'
      />
    </FixedHeaderFooter>

  _onComplete : ->
    AppDispatcher.dispatch {
      type                   : 'set-selected-ingredient-tags'
      selectedIngredientTags : @refs.ingredientList.state.selectedIngredientTags
    }
    @props.onComplete()
}


DUMMY_RECIPES = [
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
        Once you've selected ingredients, you'll get a list of things you can make. You can even include recipes
        missing an ingredient or two for those times you don't mind going to the corner store.
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
    alphabeticalIngredients : React.PropTypes.array.isRequired
    selectedIngredientTags  : React.PropTypes.object.isRequired
    onComplete              : React.PropTypes.func.isRequired

  getInitialState : -> {
    temporarySelectedIngredientTags : _.clone @props.selectedIngredientTags
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
      footer={<TitleBar onTouchTap={@_finish}>Continue</TitleBar>}
    >
      <List>
        {for ingredient in @props.alphabeticalIngredients
          <List.Item key={ingredient.tag} onTouchTap={@_ingredientSelector ingredient.tag}>
            <span className='name'>{ingredient.display}</span>
            {if @state.temporarySelectedIngredientTags[ingredient.tag]
              <i className='fa fa-check-circle'/>}
          </List.Item>}
      </List>
    </FixedHeaderFooter>

  _ingredientSelector : (tag) ->
    return =>
      # It is VERY IMPORTANT that these create a new instance: this is how PureRenderMixin guarantees correctness.
      if @state.temporarySelectedIngredientTags[tag]?
        temporarySelectedIngredientTags = _.omit @state.temporarySelectedIngredientTags, tag
      else
        temporarySelectedIngredientTags = _.clone @state.temporarySelectedIngredientTags
        temporarySelectedIngredientTags[tag] = true
      @setState { temporarySelectedIngredientTags }

  _finish : ->
    AppDispatcher.dispatch {
      type                   : 'set-selected-ingredient-tags'
      selectedIngredientTags : @state.temporarySelectedIngredientTags
    }
    @props.onComplete()
}

SummaryPage = React.createClass {
  displayName : 'SummaryPage'

  mixins : [ PureRenderMixin ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  render : ->
    <FixedHeaderFooter
      className='ftue-page explanation-page summary-page'
      header={<TitleBar>Spirit Guide</TitleBar>}
      footer={<TitleBar onTouchTap={@props.onComplete}>Finish</TitleBar>}
    >
      <h3>Almost There!</h3>
      <p>
        Now that you've picked your ingredients, you're pretty much ready to go.
      </p>
      <p>
        If you want to edit the list of ingredients you have, just tap <Isvg src='/assets/img/ingredients.svg'/>.
      </p>
      <p>
        You can add new recipes by tapping <i className='fa fa-plus'/>.
      </p>
      <h3>
        Enjoy!
      </h3>
    </FixedHeaderFooter>
}

ORDERED_PAGE_CLASSES = [
  WelcomePage
  SampleIngredientPage
  MixabilityPage
  SubstitionPage
  IngredientsPage
  SummaryPage
]

FtueView = React.createClass {
  displayName : 'FtueView'

  mixins : [
    PureRenderMixin
    FluxMixin IngredientStore, 'alphabeticalIngredients', 'groupedIngredients', 'selectedIngredientTags'
  ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  getInitialState : -> {
    currentPageIndex : 0
  }

  render : ->
    PageClass = ORDERED_PAGE_CLASSES[@state.currentPageIndex]
    if @state.currentPageIndex == ORDERED_PAGE_CLASSES.length - 1
      onComplete = @props.onComplete
    else
      onComplete = _.partial @_goToPage, @state.currentPageIndex + 1
    return <PageClass {...@state} onComplete={onComplete}/>

  _goToPage : (currentPageIndex) ->
    @setState { currentPageIndex }
}

module.exports = FtueView

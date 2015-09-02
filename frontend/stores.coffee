_          = require 'lodash'
reqwest    = require 'reqwest'
log        = require 'loglevel'
MicroEvent = require 'microevent'
Promise    = require 'bluebird'

normalization = require '../shared/normalization'
definitions   = require '../shared/definitions'

AppDispatcher = require './AppDispatcher'
RecipeSearch  = require './recipes/RecipeSearch'


ONE_MINUTE_MS = 1000 * 60
LAST_PERSIST_KEY = 'drinks-app-persist-timestamp'

class FluxStore
  MicroEvent.mixin this

  constructor : ->
    _persistable = !!@localStorageKey and !!@persistableFields

    _.extend @, _.result(@, 'fields')
    if _persistable
      persistedFields = _.pick JSON.parse(localStorage[@localStorageKey] ? '{}'), @persistableFields
      if localStorage[LAST_PERSIST_KEY]? and @persistenceTimeouts?
        msSincePersistence = Date.now() - +localStorage[LAST_PERSIST_KEY]
        persistedFields = _.pick persistedFields, (_, key) => msSincePersistence < (@persistenceTimeouts[key] ? Infinity)
      _.extend @, persistedFields

    @dispatchToken = AppDispatcher.register (payload) =>
      if this[payload.type]?
        this[payload.type](payload)
        if _persistable
          localStorage[@localStorageKey] = JSON.stringify _.pick(@, @persistableFields)
          localStorage[LAST_PERSIST_KEY] = Date.now()
        @trigger 'change'

      return true


ANY_BASE_LIQUOR = 'any'


IngredientStore = new class extends FluxStore
  fields : -> {
    searchTerm                 : ''
    alphabeticalIngredients    : []
    allAlphabeticalIngredients : []
    groupedIngredients         : []
    searchedGroupedIngredients : []
    selectedIngredientTags     : {}
    ingredientsByTag           : {}
    baseLiquors                : [ ANY_BASE_LIQUOR ].concat definitions.BASE_LIQUORS
  }

  localStorageKey : 'drinks-app-ingredients'

  persistableFields : [ 'selectedIngredientTags' ]

  'set-ingredients' : ({ groupedIngredients, intangibleIngredients, alphabeticalIngredientTags }) ->
    @groupedIngredients = groupedIngredients

    ingredients = _.chain groupedIngredients
      .pluck 'ingredients'
      .flatten()
      .value()

    @ingredientsByTag = _.chain ingredients
      .filter (i) -> i.tag?
      .reduce ((map, i) -> map[i.tag] = i ; return map), {}
      .value()

    for i in intangibleIngredients
      @ingredientsByTag[i.tag] = i
      ingredients.push i

    for i in ingredients
      if i.generic? and not @ingredientsByTag[i.generic]?
        log.trace "ingredient #{i.tag} refers to unknown generic #{i.generic}; inferring generic"
        @ingredientsByTag[i.generic] = normalization.normalizeIngredient {
          tag     : i.generic
          display : "[inferred] #{i.generic}"
        }

    @allAlphabeticalIngredients = _.map alphabeticalIngredientTags, (t) => @ingredientsByTag[t]
    @alphabeticalIngredients = _.filter @allAlphabeticalIngredients, 'tangible'

    @_updateSearchedIngredients()

  'set-selected-ingredient-tags' : ({ selectedIngredientTags }) ->
    @selectedIngredientTags = selectedIngredientTags

  'search-ingredients' : ({ searchTerm }) ->
    @searchTerm = searchTerm.toLowerCase()
    @_updateSearchedIngredients()

  _updateSearchedIngredients : ->
    if @searchTerm == ''
      @searchedGroupedIngredients = @groupedIngredients
    else
      filterBySearchTerm = (i) =>
        for term in i.searchable
          if term.indexOf(@searchTerm) != -1
            return true
        return false

      @searchedGroupedIngredients = _.chain @groupedIngredients
        .map ({ name, ingredients }) ->
          ingredients = _.filter ingredients, filterBySearchTerm
          return { name, ingredients }
        .filter ({ ingredients }) -> ingredients.length > 0
        .value()



MIXABILITY_FILTER_RANGES = {
  mixable          : [ 0, 0 ]
  nearMixable      : [ 1, 1 ]
  notReallyMixable : [ 2, 100 ]
}

UiStore = new class extends FluxStore
  fields : -> {
    baseLiquorFilter     : ANY_BASE_LIQUOR
    recipeViewingIndex   : null
    mixabilityFilters    :
      mixable          : true
      nearMixable      : true
      notReallyMixable : true
  }

  localStorageKey : 'drinks-app-ui'

  persistableFields : [ 'mixabilityFilters', 'baseLiquorFilter', 'recipeViewingIndex' ]

  persistenceTimeouts :
    baseLiquorFilter   : ONE_MINUTE_MS * 15
    # Since the current index is dependent on the filters (namely: mixability, keyword, base liquor),
    # it has to have a timeout less than or equal to the minimum of those timeouts, here 5 minutes.
    recipeViewingIndex : ONE_MINUTE_MS * 5

  'toggle-mixability-filter' : ({ filter }) ->
    @mixabilityFilters = _.clone @mixabilityFilters
    @mixabilityFilters[filter] = not @mixabilityFilters[filter]

  'set-mixability-filters' : ({ filters }) ->
    @mixabilityFilters = _.pick filters, _.keys(@mixabilityFilters)

  'set-base-liquor-filter' : ({ filter }) ->
    @baseLiquorFilter = filter

  'set-recipe-viewing-index' : ({ index }) ->
    @recipeViewingIndex = index

RecipeStore = new class extends FluxStore
  fields : -> {
    searchTerm           : ''
    mixabilityByRecipeId : {}

    allRecipes     : []
    defaultRecipes : []
    customRecipes  : []

    alphabeticalRecipes         : []
    filteredAlphabeticalRecipes : []
  }

  localStorageKey : 'drinks-app-recipes'

  persistableFields : [ 'customRecipes', 'searchTerm' ]

  persistenceTimeouts :
    searchTerm : ONE_MINUTE_MS * 5

  'set-ingredients' : ({ alphabetical, grouped }) ->
    @_updateDerivedRecipeLists()

  'set-default-recipes' : ({ recipes }) ->
    @defaultRecipes = recipes
    @_refreshRecipes()

  'set-selected-ingredient-tags' : ->
    @_updateDerivedRecipeLists()

  'toggle-mixability-filter' : ->
    @_updateDerivedRecipeLists()

  'set-mixability-filters' : ->
    @_updateDerivedRecipeLists()

  'set-base-liquor-filter' : ->
    @_updateDerivedRecipeLists()

  'search-recipes' : ({ searchTerm }) ->
    @searchTerm = searchTerm.toLowerCase().trim()
    @_updateSearchedRecipes()

  'save-recipe' : ({ recipe }) ->
    @customRecipes = @customRecipes.concat [ recipe ]
    @_refreshRecipes()

  'delete-recipe' : ({ recipeId }) ->
    @customRecipes = _.reject @customRecipes, { recipeId }
    @_refreshRecipes()

  _refreshRecipes : ->
    @allRecipes = @defaultRecipes.concat @customRecipes
    @_updateDerivedRecipeLists()

  _updateDerivedRecipeLists : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]

    alphabeticalRecipes = _.sortBy(@allRecipes, 'sortName')
    @_recipeSearch = new RecipeSearch IngredientStore.ingredientsByTag, alphabeticalRecipes

    @_updateMixableRecipes()
    @_updateSearchedRecipes()

  _updateMixableRecipes : ->
    AppDispatcher.waitFor [ IngredientStore.dispatchToken ]

    selectedTags = _.keys IngredientStore.selectedIngredientTags
    allMixableRecipes = @_recipeSearch.computeMixabilityForAll selectedTags

    @alphabeticalRecipes = _.chain allMixableRecipes
      .values()
      .flatten()
      .sortBy 'sortName'
      # group by should include a clause for numbers
      .groupBy (r) -> r.sortName[0].toLowerCase()
      .map (recipes, key) -> { recipes, key }
      .sortBy 'key'
      .value()

    @mixabilityByRecipeId = _.extend {}, _.map(allMixableRecipes, (recipes, missing) ->
      missing = +missing
      return _.reduce recipes, ((obj, r) -> obj[r.recipeId] = missing ; return obj), {}
    )...

    return # for loop

  _updateSearchedRecipes : ->
    AppDispatcher.waitFor [ UiStore.dispatchToken ]

    filteredRecipes = @alphabeticalRecipes

    if UiStore.baseLiquorFilter and UiStore.baseLiquorFilter != ANY_BASE_LIQUOR
      filteredRecipes = @_nestedFilter filteredRecipes, (r) ->
        if _.isString r.base
          return r.base == UiStore.baseLiquorFilter
        else if _.isArray r.base
          return UiStore.baseLiquorFilter in r.base
        else
          log.warn "recipe '#{r.name}' has a non-string, non-array base: #{r.base}"
          return false

    ranges = _.chain UiStore.mixabilityFilters
      .pick _.identity
      .map (_, f) -> MIXABILITY_FILTER_RANGES[f]
      .value()

    filteredRecipes = @_nestedFilter filteredRecipes, (r) =>
      for [ min, max ] in ranges
        if min <= @mixabilityByRecipeId[r.recipeId] <= max
          return true
      return false

    if @searchTerm
      filteredRecipes = @_nestedFilter filteredRecipes, (r) => @_recipeSearch.recipeMatchesSearchTerm r, @searchTerm

    @filteredAlphabeticalRecipes = filteredRecipes

  _nestedFilter : (list, filterFn) ->
    filteredList = []
    for { key, recipes } in list
      recipes = _.filter recipes, filterFn
      if recipes.length
        filteredList.push { key, recipes }
    return filteredList



EditableRecipeStore = new class extends FluxStore
  fields : -> {
    name         : ''
    ingredients  : []
    instructions : ''
    notes        : ''
    base         : []
  }

  'set-name' : ({ name }) ->
    @name = name

  'delete-ingredient' : ({ index }) ->
    @ingredients.splice index, 1
    @ingredients = _.clone @ingredients

  'add-ingredient' : ->
    @ingredients = @ingredients.concat [
      isEditing : true
    ]

  'commit-ingredient' : ({ index, rawText, tag }) ->
    @ingredients[index] = @_parseIngredient rawText, tag
    @ingredients = _.clone @ingredients

  'set-instructions' : ({ instructions }) ->
    @instructions = instructions

  'set-notes' : ({ notes }) ->
    @notes = notes

  'toggle-base-liquor-tag' : ({ tag }) ->
    if tag in @base
      @base = _.without @base, tag
    else
      # concat, don't push, b/c PureRenderMixin.
      @base = @base.concat [ tag ]

  'save-recipe' : ->
    @_clear()

  'clear-editable-recipe' : ->
    @_clear()

  _clear : ->
    _.extend @, @fields()

  COUNT_REGEX = /^[-. \/\d]+/

  MEASUREMENTS = [
    'ml'
    'cl'
    'l'
    'liter'
    'oz'
    'ounce'
    'pint'
    'part'
    'shot'
    'tsp'
    'teaspoon'
    'tbsp'
    'tablespoon'
    'cup'
    'bottle'
    'barspoon'
    'dash'
    'dashes'
    'drop'
    'pinch'
    'pinches'
    'slice'
  ]

  _parseIngredient : (rawText, tag) ->
    text = rawText.trim()

    if match = COUNT_REGEX.exec text
      displayAmount = match[0]
      text = text[displayAmount.length..].trim()

    possibleUnit = text.split(' ')[0]
    if possibleUnit in MEASUREMENTS or _.any(MEASUREMENTS, (m) -> possibleUnit == m + 's')
      displayUnit = possibleUnit
      text = text[displayUnit.length..].trim()

    displayIngredient = text

    return {
      raw       : rawText
      isEditing : false
      tag       : tag
      display   : _.pick { displayAmount, displayUnit, displayIngredient }, _.identity
    }


seedStores = _.once ->
  return Promise.all [
    Promise.resolve reqwest({
      url    : '/ingredients'
      method : 'get'
      type   : 'json'
    })
    .then (ingredients) =>
      AppDispatcher.dispatch _.extend {
        type : 'set-ingredients'
      }, ingredients
  ,
    Promise.resolve reqwest({
      url    : '/recipes'
      method : 'get'
      type   : 'json'
    })
    .then (recipes) =>
      AppDispatcher.dispatch {
        type : 'set-default-recipes'
        recipes
      }
  ]

module.exports = {
  seedStores

  IngredientStore
  RecipeStore
  UiStore
  EditableRecipeStore
}

_.extend window.debug, module.exports

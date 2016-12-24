_   = require 'lodash'
log = require 'loglevel'

ONE_MINUTE_MS    = 1000 * 60
LOCALSTORAGE_KEY = 'drinks-app-persistence'
PERSISTENCE_SPEC = {
  filters :
    recipeSearchTerm       : ONE_MINUTE_MS * 5
    baseLiquorFilter       : ONE_MINUTE_MS * 15
    selectedIngredientTags : Infinity
    selectedRecipeList     : ONE_MINUTE_MS * 60
  recipes :
    customRecipeIds : Infinity
  ui :
    errorMessage             : 0
    recipeViewingIndex       : ONE_MINUTE_MS * 5
    currentlyViewedRecipeIds : ONE_MINUTE_MS * 5
    favoritedRecipeIds       : Infinity
    showingRecipeViewer      : ONE_MINUTE_MS * 5
    showingRecipeEditor      : Infinity
    showingSidebar           : ONE_MINUTE_MS * 5
    showingListSelector      : ONE_MINUTE_MS
  editableRecipe :
    originalRecipeId : Infinity
    currentPage      : Infinity
    name             : Infinity
    ingredients      : Infinity
    instructions     : Infinity
    notes            : Infinity
    base             : Infinity
    saving           : 0
}

watch = (store) ->
  store.subscribe _.debounce (->
    state = store.getState()

    data = _.mapValues PERSISTENCE_SPEC, (spec, storeName) ->
      return _.pick state[storeName], _.keys(spec)

    timestamp = Date.now()
    localStorage[LOCALSTORAGE_KEY] = JSON.stringify { data, timestamp }

    log.debug "persisted data at t=#{timestamp}"
  ), 1000

load = _.once ->
  { data, timestamp } = JSON.parse(localStorage[LOCALSTORAGE_KEY] ? '{}')

  if not data?
    # Legacy version.
    ui          = JSON.parse(localStorage['drinks-app-ui'] ? '{}')
    recipes     = JSON.parse(localStorage['drinks-app-recipes'] ? '{}')
    ingredients = JSON.parse(localStorage['drinks-app-ingredients'] ? '{}')

    return _.mapValues {
      filters :
        recipeSearchTerm       : recipes.searchTerm
        baseLiquorFilter       : ui.baseLiquorFilter
        selectedIngredientTags : ingredients.selectedIngredientTags
      recipes :
        customRecipes : recipes.customRecipes
      ui :
        recipeViewingIndex : ui.recipeViewingIndex
    }, (store) -> _.omit store, _.isUndefined
  else
    elapsedTime = Date.now() - +(timestamp ? 0)

    return _.mapValues PERSISTENCE_SPEC, (spec, storeName) ->
      return _.chain data[storeName]
        .pick _.keys(spec)
        .pick (_, key) -> elapsedTime < spec[key]
        .omit _.isUndefined
        .value()

module.exports = { watch, load }

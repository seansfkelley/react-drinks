_ = require 'lodash'

ONE_MINUTE_MS    = 1000 * 60
LOCALSTORAGE_KEY = 'drinks-app-persistence'
PERSISTENCE_SPEC = {
  filters :
    recipeSearchTerm       : ONE_MINUTE_MS * 5
    baseLiquorFilter       : ONE_MINUTE_MS * 15
    includeAllDrinks       : Infinity
    selectedIngredientTags : Infinity
    selectedRecipeList     : ONE_MINUTE_MS * 60
  recipes :
    customRecipes : Infinity
  ui :
    recipeViewingIndex       : ONE_MINUTE_MS * 5
    currentlyViewedRecipeIds : ONE_MINUTE_MS * 5
    favoritedRecipeIds       : Infinity
    showingRecipeViewer      : ONE_MINUTE_MS * 5
    # Should support this, eventually.
    # showingRecipeEditor      : ONE_MINUTE_MS * 5
    showingSidebar           : ONE_MINUTE_MS * 5
}

watch = (store) ->
  store.subscribe _.debounce (->
    state = store.getState()

    data = _.mapValues PERSISTENCE_SPEC, (spec, storeName) ->
      return _.pick state[storeName], _.keys(spec)

    localStorage[LOCALSTORAGE_KEY] = JSON.stringify {
      data
      timestamp : Date.now()
    }
  ), 1000

load = ->
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

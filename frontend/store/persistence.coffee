_ = require 'lodash'

ONE_MINUTE_MS    = 1000 * 60
LOCALSTORAGE_KEY = 'drinks-app-persistence'
PERSISTENCE_SPEC = {
  filters :
    recipeSearchTerm       : ONE_MINUTE_MS * 5
    baseLiquorFilter       : ONE_MINUTE_MS * 15
    mixabilityFilters      : Infinity
    selectedIngredientTags : Infinity
  recipes :
    customRecipes : Infinity
  ui :
    recipeViewingIndex : ONE_MINUTE_MS * 5
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

  data ?= {}
  elapsedTime = Date.now() - +(timestamp ? 0)

  return _.mapValues PERSISTENCE_SPEC, (spec, storeName) ->
    return _.chain data[storeName]
      .pick _.keys(spec)
      .pick (_, key) -> elapsedTime < spec[key]
      .value()

module.exports = { watch, load }

_ = require 'lodash'

store = require '.'

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

watch = ->
  store.subscribe ->
    state = store.getState()

    data = _.mapValues PERSISTENCE_SPEC, (spec, storeName) ->
      return _.pick state[storeName], _.keys(spec)

    console.log data

    # localStorage[LOCALSTORAGE_KEY] = JSON.stringify {
    #   data
    #   timestamp : Date.now()
    # }

load = ->
  { data, timestamp } = JSON.parse(localStorage[LOCALSTORAGE_KEY] ? '{}')

  data ?= {}
  elapsedTime = Date.now() - +(timestamp ? 0)

  payload = _.mapValues PERSISTENCE_SPEC, (spec, storeName) ->
    return _.chain data[storeName]
      .pick _.keys(spec)
      .pick (_, key) -> elapsedTime < spec[key]
      .value()

  console.log payload

  # store.dispatch {
  #   type : 'load-persistence'
  #   payload
  # }

module.exports = { watch, load }

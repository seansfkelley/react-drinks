_ = require 'lodash'

store = require '../store'

ReduxMixin = (fieldsBySubstore) ->
  fnName = _.uniqueId '_onStoreChange_'
  getFlattenedFields = ->
    state = store.getState()
    return _.extend {}, _.map(fieldsBySubstore, (fields, storeName) ->
      return _.pick state[storeName], fields
    )...

  mixin = {
    getInitialState : getFlattenedFields

    componentDidMount : ->
      @_reduxUnsubscribe = store.subscribe @[fnName]

    componentWillUnmount : ->
      @_reduxUnsubscribe?()
  }

  mixin[fnName] = ->
    @setState getFlattenedFields()

  return mixin

module.exports = ReduxMixin

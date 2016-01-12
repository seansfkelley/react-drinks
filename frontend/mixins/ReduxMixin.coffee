_ = require 'lodash'

store = require '../store'

ReduxMixin = (fieldsBySubstore) ->
  fnName = _.uniqueId '_onStoreChange_'
  getFlattenedFields = ->
    state = store.getState()
    return _.extend {}, _.map(fieldsBySubstore, (fieldArrayOrString, storeName) ->
      return _.pick state[storeName], fieldArrayOrString
    )...

  mixin = {
    getInitialState : getFlattenedFields

    componentDidMount : ->
      @_reduxMixin_unsubscribe = store.subscribe @[fnName]

    componentWillUnmount : ->
      @_reduxMixin_unsubscribe()
      # See https://github.com/rackt/redux/issues/1180
      @_reduxMixin_hack_isUnsubscribed = true
  }

  mixin[fnName] = ->
    if not @_reduxMixin_hack_isUnsubscribed
      @setState getFlattenedFields()

  return mixin

module.exports = ReduxMixin

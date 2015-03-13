_ = require 'lodash'

FluxMixin = (store, fields...) ->
  fields = _.flatten fields
  fnName = _.uniqueId '_onStoreChange_'
  mixin = {
    getInitialState : ->
      return _.pick store, fields

    componentDidMount : ->
      store.bind 'change', @[fnName]

    componentWillUnmount : ->
      store.unbind 'change', @[fnName]
  }

  mixin[fnName] = ->
    @setState _.pick(store, fields)

  return mixin

module.exports = FluxMixin

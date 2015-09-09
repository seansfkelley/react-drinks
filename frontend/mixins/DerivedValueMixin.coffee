_ = require 'lodash'

store   = require '../store'
derived = require '../store/derived'

DerivedValueMixin = (fieldNames...) ->
  fieldNames = _.flatten fieldNames
  fnName = _.uniqueId '_onStoreChange_'
  getDerivedFields = ->
    state = store.getState()
    return _.reduce(fieldNames, ((fields, fieldName) ->
      fields[fieldName] = derived[fieldName](state)
      return fields
    ), {})

  mixin = {
    getInitialState : getDerivedFields

    componentDidMount : ->
      @_derivedValueMixin_unsubscribe = store.subscribe @[fnName]

    componentWillUnmount : ->
      @_derivedValueMixin_unsubscribe?()
  }

  mixin[fnName] = ->
    @setState getDerivedFields()

  return mixin

module.exports = DerivedValueMixin

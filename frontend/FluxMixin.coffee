window.FluxMixin = (store, fields...) ->
  fields = _.flatten fields
  return {
    getInitialState : ->
      return _.pick store, fields

    componentDidMount : ->
      store.bind 'change', @_onStoreChange

    componentWillUnmount : ->
      store.unbind 'change', @_onStoreChange

    _onStoreChange : ->
      @setState _.pick(store, fields)
  }

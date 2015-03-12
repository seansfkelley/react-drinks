# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

Header    = require './Header'
SearchBar = require './SearchBar'

HeaderWithSearch = React.createClass {
  displayName : 'HeaderWithSearch'

  propTypes :
    onSearch : React.PropTypes.func

  getInitialState : ->
    return {
      searchBarVisible : false
    }

  render : ->
    classNames = 'with-search'
    if @props.classNames?
      classNames += @props.classNames

    <Header {...@props}
      classNames={classNames}
      rightIcon={'fa-search'}
      rightIconOnTouchTap={@_toggleSearch}
    >
      <div className={'search-bar-wrapper ' + if @state.searchBarVisible then 'visible' else 'hidden'}>
        <SearchBar onChange={@props.onSearch} key='search-bar' ref='searchBar'/>
      </div>
    </Header>

  _toggleSearch : ->
    searchBarVisible = not @state.searchBarVisible
    @setState { searchBarVisible }
    if searchBarVisible
      # This defer is a hack because we haven't rerendered but we can't focus hidden things.
      _.defer =>
        @refs.searchBar.clearAndFocus()
    else
      @refs.searchBar.clear()
}

module.exports = HeaderWithSearch

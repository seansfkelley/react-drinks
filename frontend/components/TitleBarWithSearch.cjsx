# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

ClassNameMixin = require '../mixins/ClassNameMixin'

TitleBar  = require './TitleBar'
SearchBar = require './SearchBar'

TitleBarWithSearch = React.createClass {
  displayName : 'TitleBarWithSearch'

  propTypes :
    onSearch    : React.PropTypes.func.isRequired
    placeholder : React.PropTypes.string

  mixins : [
    ClassNameMixin
  ]

  getInitialState : ->
    return {
      searchBarVisible : false
    }

  render : ->
    renderableProps = _.omit @props, 'placeholder'
    <TitleBar {...renderableProps}
      className={@getClassName 'with-search'}
      rightIcon={'fa-search'}
      rightIconOnTouchTap={@_toggleSearch}
    >
      <div className={'search-bar-wrapper ' + if @state.searchBarVisible then 'visible' else 'hidden'}>
        <SearchBar onChange={@props.onSearch} key='search-bar' ref='searchBar' placeholder={@props.placeholder}/>
      </div>
    </TitleBar>

  _toggleSearch : ->
    searchBarVisible = not @state.searchBarVisible
    @setState { searchBarVisible }
    if searchBarVisible
      @refs.searchBar.clearAndFocus()
    else
      @refs.searchBar.clear()
      document.activeElement?.blur()

  componentDidMount : ->
    if @state.searchBarVisible
      @refs.searchBar.clearAndFocus()

}

module.exports = TitleBarWithSearch

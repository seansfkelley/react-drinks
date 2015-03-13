# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

ListHeader = require './ListHeader'

StickyHeaderMixin = {
  getInitialState : ->
    return {
      stickyHeaderTitle  : null
      stickyHeaderOffset : 0
    }

  # TODO: Make this a class that takes a bunch of children.
  generateList : ({ data, getTitle, createChild, className }) ->
    lastTitle = null
    childNodes = _.chain data
      .map (datum, i) ->
        newTitle = getTitle datum
        if newTitle != lastTitle
          elements = [ <ListHeader title={newTitle} key={'header-' + newTitle} ref={'header-' + newTitle}/> ]
          lastTitle = newTitle
        else
          elements = []

        return elements.concat [ createChild datum, i ]
      .flatten()
      .value()

    if childNodes.length == 0
      childNodes = [
        <div className='empty-list-text' key='empty'>Nothing to see here.</div>
      ]

    <div className='sticky-header-container' onScroll={@_stickHeaderOnScroll}>
      {if @state.stickyHeaderTitle?
        <div className='sticky-header-wrapper' style={{ marginTop : @state.stickyHeaderOffset }}>
          <ListHeader title={@state.stickyHeaderTitle}/>
        </div>}
      <div className={'sticky-header-list ' + className}>
        {childNodes}
      </div>
    </div>

  _stickHeaderOnScroll : (e) ->
    scrollTop = @getDOMNode().getBoundingClientRect().top
    refTopPairs = _.chain(@refs)
      .filter (_, refName) -> refName[...7] == 'header-'
      .map (ref) -> [ ref, ref.getDOMNode().getBoundingClientRect().top - scrollTop ]
      .sortBy ([ ref, top ]) -> top
      .value()

    for [ ref, top ], i in refTopPairs
      if top > 0
        previous = refTopPairs[i - 1]
        current  = refTopPairs[i]
        break

    if previous? and current?
      @setState {
        stickyHeaderTitle  : previous[0].props.title
        stickyHeaderOffset : Math.min (current[1] - current[0].getDOMNode().getBoundingClientRect().height), 0
      }
    else
      @setState {
        stickyHeaderTitle  : null
        stickyHeaderOffset : 0
      }
}

module.exports = StickyHeaderMixin

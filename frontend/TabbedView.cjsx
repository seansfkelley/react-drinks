# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

TabBar = React.createClass {
  render : ->
    tabs = @props.tabs.map (t) =>
      tabClass = 'tab'
      if @props.active == t
        tabClass += ' active'
      <div className={tabClass} onClick={_.partial @props.onTabSelect, t} key={t.title}>
        <i className={'fa fa-' + t.icon}/>
        <span className='tab-title'>{t.title}</span>
      </div>

    <div className='tab-bar sticky-header-bar'>
      {tabs}
    </div>
}

TabbedView = React.createClass {
  getInitialState : ->
    return {
      active : @props.tabs[0]
    }

  render : ->
    <div className='tabbed-view sticky-header-container'>
      <TabBar tabs={@props.tabs} active={@state.active} onTabSelect={@_onTabSelect}/>
      <div className='sticky-header-content-pane'>
        {@state.active.content}
      </div>
    </div>

  _onTabSelect : (active) ->
    @setState { active }
}

module.exports = TabbedView

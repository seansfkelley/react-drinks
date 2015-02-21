# @cjsx React.DOM

React = require 'react'

TabBar = React.createClass {
  render : ->
    tabs = @props.tabs.map (t) =>
      tabClass = 'tab'
      if @props.active == t
        tabClass += ' active'
      <div className={tabClass} onClick={_.partial @props.onTabSelect, t}>
        <i className={'fa fa-' + t.icon}/>
        {t.title}
      </div>

    <div className='tab-bar'>
      {tabs}
    </div>
}

TabbedView = React.createClass {
  getInitialState : ->
    return {
      active : @props.tabs[0]
    }

  render : ->
    <div className='tabbed-view'>
      <TabBar tabs={@props.tabs} active={@state.active} onTabSelect={@_onTabSelect}/>
      {@state.active.content}
    </div>

  _onTabSelect : (active) ->
    @setState { active }
}

module.exports = TabbedView

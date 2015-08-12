_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

SidebarMenu = React.createClass {
  displayName : 'SidebarMenu'

  propTypes : {}

  getDefaultProps : ->
    return {
      initialIndex : 0
    }

  getInitialState : ->
    return {
      index : @props.initialIndex
    }

  render : ->
    <div className='sidebar-menu'>
      <div className='ingredients-button'>
        <img src='/assets/img/ingredients.svg'/>
        <span className='item-text'>Edit Ingredients</span>
      </div>
      <div className='mixability-title'>Show:</div>
      <div className='mixability-options-container'>
        <div className='input-wrapper'>
          <input type='range' min='0' max='2' value={@state.index} onChange={@_onSliderChange}/>
        </div>
        <div className='mixability-options'>
          <div className={classnames 'option', { 'is-selected' : @state.index >= 0 }} onTouchTap={@_generateLabelTapper 0}>
              Drinks I Can Make
          </div>
          <div className={classnames 'option', { 'is-selected' : @state.index >= 1 }} onTouchTap={@_generateLabelTapper 1}>
              Drinks Missing 1 Ingredient
          </div>
          <div className={classnames 'option', { 'is-selected' : @state.index >= 2 }} onTouchTap={@_generateLabelTapper 2}>
              All Drinks
          </div>
        </div>
      </div>
    </div>

  _onSliderChange : (e) ->
    @setState { index : _.parseInt(e.target.value) }

  _generateLabelTapper : (index) ->
    return =>
      @setState { index }

}

module.exports = SidebarMenu

_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

store = require '../store'

ReduxMixin = require '../mixins/ReduxMixin'

definitions = require '../../shared/definitions'

List = require '../components/List'

EditableRecipePage = require './EditableRecipePage'

EditableBaseLiquorPage = React.createClass {
  displayName : 'EditableBaseLiquorPage'

  mixins : [
    ReduxMixin {
      editableRecipe : 'base'
    }
    PureRenderMixin
  ]

  propTypes :
    onClose       : React.PropTypes.func.isRequired
    onNext        : React.PropTypes.func
    onPrevious    : React.PropTypes.func
    previousTitle : React.PropTypes.string

  render : ->
    <EditableRecipePage
      className='base-tag-page'
      onClose={@props.onClose}
      onPrevious={@props.onPrevious}
      previousTitle={@props.previousTitle}
    >
      <div className='fixed-content-pane'>
        <div className='page-title'>Base ingredient(s)</div>
        <List>
          {for tag in definitions.BASE_LIQUORS
            <List.Item
              className={classnames 'base-liquor-option', { 'is-selected' : tag in @state.base }}
              onTouchTap={@_tagToggler tag}
              key="tag-#{tag}"
            >
              {definitions.BASE_TITLES_BY_TAG[tag]}
              <i className='fa fa-check-circle'/>
            </List.Item>}
        </List>
        <div className={classnames 'next-button', { 'disabled' : not @_isEnabled() }} onTouchTap={@_nextIfEnabled}>
          <span className='next-text'>Next</span>
          <i className='fa fa-arrow-right'/>
        </div>
      </div>
    </EditableRecipePage>

  _isEnabled : ->
    return @state.base.length > 0

  _nextIfEnabled : ->
    if @_isEnabled()
      @props.onNext()

  _tagToggler : (tag) ->
    return =>
      store.dispatch {
        type : 'toggle-base-liquor-tag'
        tag
      }
}

module.exports = EditableBaseLiquorPage

_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

store = require '../store'

ReduxMixin = require '../mixins/ReduxMixin'

EditableRecipePage = require './EditableRecipePage'

EditableNamePage = React.createClass {
  displayName : 'EditableNamePage'

  mixins : [
    ReduxMixin {
      recipeEditor : 'name'
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
      className='name-page'
      onClose={@props.onClose}
      onPrevious={@props.onPrevious}
      previousTitle={@props.previousTitle}
    >
      <div className='fixed-content-pane'>
        <div className='page-title'>Add a Recipe</div>
        <input
          type='text'
          placeholder='Name...'
          autoCorrect='off'
          autoCapitalize='on'
          autoComplete='off'
          spellCheck='false'
          ref='input'
          value={@state.name}
          onChange={@_onChange}
          onTouchTap={@_focus}
        />
        <div className={classnames 'next-button', { 'disabled' : not @_isEnabled() }} onTouchTap={@_nextIfEnabled}>
          <span className='next-text'>Next</span>
          <i className='fa fa-arrow-right'/>
        </div>
      </div>
    </EditableRecipePage>

  _focus : ->
    @refs.input.focus()

  # mixin-ify this kind of stuff probably
  _isEnabled : ->
    return !!@state.name

  _nextIfEnabled : ->
    if @_isEnabled()
      store.dispatch {
        type : 'set-name'
        name : @state.name.trim()
      }
      @props.onNext()

  _onChange : (e) ->
    store.dispatch {
      type : 'set-name'
      name : e.target.value
    }
}

module.exports = EditableNamePage

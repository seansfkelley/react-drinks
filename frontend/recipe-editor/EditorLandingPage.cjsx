_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

store = require '../store'

ReduxMixin = require '../mixins/ReduxMixin'

EditableRecipePage = require './EditableRecipePage'
NextButton         = require './NextButton'

EditableNamePage = React.createClass {
  displayName : 'EditableNamePage'

  mixins : [
    ReduxMixin {
      editableRecipe : 'name'
    }
    PureRenderMixin
  ]

  propTypes :
    onClose      : React.PropTypes.func.isRequired
    onCreateNew  : React.PropTypes.func
    onEnterProse : React.PropTypes.func
    onEnterId    : React.PropTypes.func

  render : ->
    <EditableRecipePage
      className='landing-page'
      onClose={@props.onClose}
    >
      <div className='fixed-content-pane'>
        <div className='add-recipe-section new-recipe'>
          <div className='section-title'>Create New Drink</div>
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
          <NextButton
            isEnabled={@_isEnabled()}
            onNext={@_onNext}
          />
        </div>
        <div className='add-recipe-section add-prose'>
          <div className='section-title'>Recipe from Text</div>
          <textarea
            placeholder='Recipe text...'
            autoCorrect='off'
            autoCapitalize='on'
            autoComplete='off'
            spellCheck='false'
          />
          <NextButton
            isEnabled={@_isEnabled()}
            onNext={@_onNext}
          />
        </div>
        <div className='add-recipe-section add-id'>
          <div className='section-title'>Use Code</div>
          <input
            type='text'
            placeholder='Code...'
            autoCorrect='off'
            autoCapitalize='on'
            autoComplete='off'
            spellCheck='false'
          />
          <NextButton
            isEnabled={@_isEnabled()}
            onNext={@_onNext}
            text='Save'
          />
        </div>
      </div>
    </EditableRecipePage>

  _focus : ->
    @refs.input.focus()

  # mixin-ify this kind of stuff probably
  _isEnabled : ->
    return !!@state.name

  _onNext : ->
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

React      = require 'react/addons'
classnames = require 'classnames'
{ PureRenderMixin } = React.addons

utils = require '../utils'

MeasuredIngredient = React.createClass {
  displayName : 'MeasuredIngredient'

  mixins : [ PureRenderMixin ]

  propTypes :
    displayAmount      : React.PropTypes.string
    displayUnit        : React.PropTypes.string
    displayIngredient  : React.PropTypes.string.isRequired
    displaySubstitutes : React.PropTypes.array
    isMissing          : React.PropTypes.bool
    isSubstituted      : React.PropTypes.bool
    onAddRemove        : React.PropTypes.func

  getDefaultProps : -> {
    displayAmount      : ''
    displayUnit        : ''
    displaySubstitutes : []
  }

  getInitialState : -> {
    isSlidOver : false
  }

  _onEllipsisTap : ->
    if @state.isSlidOver
      clearTimeout @_unslideTimeout
    else
      @_unslideTimeout = setTimeout @_unslide, 3000

    @setState { isSlidOver : not @state.isSlidOver }

  _unslide : ->
    @setState { isSlidOver : false }

  render : ->
    # The space is necessary to space out the spans from each other. Newlines are insufficient.
    # Include the keys only to keep React happy so that it warns us about significant uses of
    # arrays without key props.
    <div className={classnames 'measured-ingredient', @props.className, {
        'missing'      : @props.isMissing
        'substituted'  : @props.isSubstituted
        'is-slid-over' : @state.isSlidOver
    }}>
      <div className='slideover-wrapper'>
        <span className='measure'>
          <span className='amount'>{utils.fractionify @props.displayAmount}</span>
          {' '}
          <span className='unit'>{@props.displayUnit}</span>
        </span>
        <span className='ingredient'>
          <span className='name'>{@props.displayIngredient}</span>
          {if @props.displaySubstitutes.length then [
            <span className='substitute-label' key='label'>try:</span>
            <span className='substitute-content' key='content'>{@props.displaySubstitutes}</span>]}
        </span>
        {if @props.onAddRemove
          <i className='fa fa-ellipsis-h ellipsis-button' onTouchTap={@_onEllipsisTap}/>}
      </div>
      {if @props.onAddRemove
        <div
          className={classnames 'add-remove-button', { 'add' : @props.isMissing, 'remove' : not @props.isMissing }}
          onTouchTap={@props.onAddRemove}
        >
          <span className='text'>
            {if @props.isMissing then 'Add' else 'Remove'}
          </span>
        </div>}
    </div>
}

module.exports = MeasuredIngredient

_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

store = require '../store'

{ parseIngredientFromText } = require '../utils'

ReduxMixin = require '../mixins/ReduxMixin'

EditableRecipePage = require './EditableRecipePage'

Deletable = require '../components/Deletable'
List      = require '../components/List'

MeasuredIngredient = require '../recipes/MeasuredIngredient'

EditableIngredient = React.createClass {
  displayName : 'EditableIngredient'

  propTypes :
    addIngredient              : React.PropTypes.func.isRequired
    ingredientsByTag           : React.PropTypes.object.isRequired
    allAlphabeticalIngredients : React.PropTypes.array.isRequired

  getInitialState : -> {
    tag         : null
    value       : ''
    guessedTags : []
  }

  render : ->
    if @state.tag?
      ingredientSelector = <List.Item>
        {@props.ingredientsByTag[@state.tag].display}
        <i className='fa fa-times-circle' onTouchTap={@_unsetTag}/>
      </List.Item>
    else
      ingredientSelector = _.map @state.guessedTags, (tag) =>
        <List.Item onTouchTap={@_tagSetter tag} key="tag-#{tag}">{@props.ingredientsByTag[tag].display}</List.Item>

      if ingredientSelector.length
        ingredientSelector.push <div className='section-separator' key='separator'/>

      ingredientSelector = ingredientSelector.concat(_.chain(@props.allAlphabeticalIngredients)
        .filter ({ tag }) => tag not in @state.guessedTags
        .map ({ display, tag }) =>
          <List.Item onTouchTap={@_tagSetter tag} key="tag-#{tag}">{display}</List.Item>
        .value()
      )

    <div className='editable-ingredient'>
      <div className='input-line'>
        <input
          type='text'
          placeholder='ex: 1 oz gin'
          autoCorrect='off'
          autoCapitalize='off'
          autoComplete='off'
          spellCheck='false'
          ref='input'
          value={@state.value}
          onChange={@_onChange}
          onTouchTap={@_focus}
        />
        <div
          className={classnames 'done-button', { 'disabled' : not @_isCommittable() }}
          onTouchTap={@_commitIfAllowed}
        >
          Done
          <i className='fa fa-check-circle'/>
        </div>
      </div>
      <div className='ingredient-list-header'>A Type Of</div>
      <List className='ingredient-group-list' onTouchStart={@_dismissKeyboard}>
        {ingredientSelector}
      </List>
    </div>

  componentDidMount : ->
    @_guessTags = _.throttle @_guessTags, 250

  componentWillUnmount : ->
    @_guessTags.cancel()

  _focus : ->
    @refs.input.focus()

  _dismissKeyboard : ->
    @refs.input.blur()

  _tagSetter : (tag) ->
    return =>
      @setState { tag }

  _unsetTag : ->
    @setState { tag : null }

  _isCommittable : ->
    return !!@state.value.trim()

  _commitIfAllowed : ->
    if @_isCommittable()
      @props.addIngredient @state.value.trim(), @state.tag

  _onChange : (e) ->
    @setState { value : e.target.value }
    @_guessTags e.target.value

  _guessTags : (value) ->
    { displayIngredient } = parseIngredientFromText value
    if not displayIngredient
      @setState { guessedTags : [] }
    else
      # This is probably dumb slow.
      words = _.deburr(displayIngredient).split ' '
      guessedTags = _.chain(@props.allAlphabeticalIngredients)
        .filter ({ searchable }) ->
          _.any words, (w) ->
            _.any searchable, (s) ->
              s.indexOf(w) != -1
        .pluck 'tag'
        .value()

      @setState { guessedTags }

}

EditableIngredientsPage = React.createClass {
  displayName : 'EditableIngredientsPage'

  mixins : [
    ReduxMixin {
      recipeEditor : 'ingredients'
      ingredients    : [ 'ingredientsByTag', 'allAlphabeticalIngredients' ]
    }
    PureRenderMixin
  ]

  propTypes :
    onClose       : React.PropTypes.func.isRequired
    onNext        : React.PropTypes.func
    onPrevious    : React.PropTypes.func
    previousTitle : React.PropTypes.string

  render : ->
    ingredientNodes = _.map @state.ingredients, (ingredient, index) =>
      if ingredient.isEditing
        ingredientNode = <EditableIngredient
          addIngredient={@_ingredientAdder index}
          ingredientsByTag={@state.ingredientsByTag}
          allAlphabeticalIngredients={@state.allAlphabeticalIngredients}
        />
      else
        ingredientNode = <MeasuredIngredient {...ingredient.display}/>

      return <Deletable
        onDelete={@_ingredientDeleter index}
        key="tag-#{ingredient.tag ? ingredient.display?.displayIngredient}-#{index}"
      >
        {ingredientNode}
      </Deletable>

    <EditableRecipePage
      className='ingredients-page'
      onClose={@props.onClose}
      onPrevious={@props.onPrevious}
      previousTitle={@props.previousTitle}
    >
      <div className='fixed-content-pane'>
        <div className='ingredients-list'>
          {ingredientNodes}
        </div>
        <div className={classnames 'new-ingredient-button', { 'disabled' : @_anyAreEditing() }} onTouchTap={@_addEmptyIngredient}>
          <i className='fa fa-plus-circle'/>
          <span>New Ingredient</span>
        </div>
        <div className={classnames 'next-button', { 'disabled' : not @_isEnabled() }} onTouchTap={@_nextIfEnabled}>
          <span className='next-text'>Next</span>
          <i className='fa fa-arrow-right'/>
        </div>
      </div>
    </EditableRecipePage>

  _anyAreEditing : ->
    return _.any @state.ingredients, 'isEditing'

  _isEnabled : ->
    return @state.ingredients.length > 0 and not _.any(@state.ingredients, 'isEditing')

  _nextIfEnabled : ->
    if @_isEnabled()
      @props.onNext()

  _addEmptyIngredient : ->
    return if @_anyAreEditing()

    store.dispatch {
      type : 'add-ingredient'
    }

  _ingredientAdder : (index) ->
    return (rawText, tag) =>
      store.dispatch {
        type : 'commit-ingredient'
        index
        rawText
        tag
      }

  _ingredientDeleter : (index) ->
    return =>
      store.dispatch {
        type : 'delete-ingredient'
        index
      }
}

module.exports = EditableIngredientsPage

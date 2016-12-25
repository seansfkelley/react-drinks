
import * as React from 'react';
import * as classNames from 'classnames';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import store from '../store';

const { parseIngredientFromText } = require('../utils');

import ReduxMixin from '../mixins/ReduxMixin';

import EditableRecipePage from './EditableRecipePage';

import Deletable from '../components/Deletable';
import List from '../components/List';

import MeasuredIngredient from '../recipes/MeasuredIngredient';

const EditableIngredient = React.createClass({
  displayName: 'EditableIngredient',

  propTypes: {
    addIngredient: React.PropTypes.func.isRequired,
    ingredientsByTag: React.PropTypes.object.isRequired,
    allAlphabeticalIngredients: React.PropTypes.array.isRequired
  },

  getInitialState() {
    return {
      tag: null,
      value: '',
      guessedTags: []
    };
  },

  render() {
    let ingredientSelector;
    if (this.state.tag != null) {
      ingredientSelector = <List.Item>{this.props.ingredientsByTag[this.state.tag].display}<i className='fa fa-times-circle' onClick={this._unsetTag} /></List.Item>;
    } else {
      ingredientSelector = _.map(this.state.guessedTags, tag => {
        return <List.Item onClick={this._tagSetter(tag)} key={`tag-${ tag }`}>{this.props.ingredientsByTag[tag].display}</List.Item>;
      });

      if (ingredientSelector.length) {
        ingredientSelector.push(<div className='section-separator' key='separator' />);
      }

      ingredientSelector = ingredientSelector.concat(_.chain(this.props.allAlphabeticalIngredients).filter(({ tag }) => !this.state.guessedTags.includes(tag)).map(({ display, tag }) => {
        return <List.Item onClick={this._tagSetter(tag)} key={`tag-${ tag }`}>{display}</List.Item>;
      }).value());
    }

    return <div className='editable-ingredient'><div className='input-line'><input type='text' placeholder='ex: 1 oz gin' autoCorrect='off' autoCapitalize='off' autoComplete='off' spellCheck='false' ref='input' value={this.state.value} onChange={this._onChange} onClick={this._focus} /><div className={classNames('done-button', { 'disabled': !this._isCommittable() })} onClick={this._commitIfAllowed}>Done<i className='fa fa-check-circle' /></div></div><div className='ingredient-list-header'>A Type Of</div><List className='ingredient-group-list' onTouchStart={this._dismissKeyboard}>{ingredientSelector}</List></div>;
  },

  componentDidMount() {
    return this._guessTags = _.throttle(this._guessTags, 250);
  },

  componentWillUnmount() {
    return this._guessTags.cancel();
  },

  _focus() {
    return this.refs.input.focus();
  },

  _dismissKeyboard() {
    return this.refs.input.blur();
  },

  _tagSetter(tag) {
    return () => {
      return this.setState({ tag });
    };
  },

  _unsetTag() {
    return this.setState({ tag: null });
  },

  _isCommittable() {
    return !!this.state.value.trim();
  },

  _commitIfAllowed() {
    if (this._isCommittable()) {
      return this.props.addIngredient(this.state.value.trim(), this.state.tag);
    }
  },

  _onChange(e) {
    this.setState({ value: e.target.value });
    return this._guessTags(e.target.value);
  },

  _guessTags(value) {
    const { displayIngredient } = parseIngredientFromText(value);
    if (!displayIngredient) {
      return this.setState({ guessedTags: [] });
    } else {
      // This is probably dumb slow.
      const words = _.deburr(displayIngredient).split(' ');
      const guessedTags = _.chain(this.props.allAlphabeticalIngredients).filter(({ searchable }) => _.any(words, w => _.any(searchable, s => s.indexOf(w) !== -1))).pluck('tag').value();

      return this.setState({ guessedTags });
    }
  }

});

export default React.createClass({
  displayName: 'EditableIngredientsPage',

  mixins: [ReduxMixin({
    editableRecipe: 'ingredients',
    ingredients: ['ingredientsByTag', 'allAlphabeticalIngredients']
  }), PureRenderMixin],

  propTypes: {
    onClose: React.PropTypes.func.isRequired,
    onNext: React.PropTypes.func,
    onPrevious: React.PropTypes.func,
    previousTitle: React.PropTypes.string
  },

  render() {
    const ingredientNodes = _.map(this.state.ingredients, (ingredient, index) => {
      let ingredientNode;
      if (ingredient.isEditing) {
        ingredientNode = <EditableIngredient addIngredient={this._ingredientAdder(index)} ingredientsByTag={this.state.ingredientsByTag} allAlphabeticalIngredients={this.state.allAlphabeticalIngredients} />;
      } else {
        ingredientNode = <MeasuredIngredient {...Object.assign({}, ingredient.display)} />;
      }

      return <Deletable onDelete={this._ingredientDeleter(index)} key={`tag-${ ingredient.tag != null ? ingredient.tag : __guard__(ingredient.display, x => x.displayIngredient) }-${ index }`}>{ingredientNode}</Deletable>;
    });

    return <EditableRecipePage className='ingredients-page' onClose={this.props.onClose} onPrevious={this.props.onPrevious} previousTitle={this.props.previousTitle}><div className='fixed-content-pane'><div className='ingredients-list'>{ingredientNodes}</div><div className={classNames('new-ingredient-button', { 'disabled': this._anyAreEditing() })} onClick={this._addEmptyIngredient}><i className='fa fa-plus-circle' /><span>New Ingredient</span></div><div className={classNames('next-button', { 'disabled': !this._isEnabled() })} onClick={this._nextIfEnabled}><span className='next-text'>Next</span><i className='fa fa-arrow-right' /></div></div></EditableRecipePage>;
  },

  _anyAreEditing() {
    return _.any(this.state.ingredients, 'isEditing');
  },

  _isEnabled() {
    return this.state.ingredients.length > 0 && !_.any(this.state.ingredients, 'isEditing');
  },

  _nextIfEnabled() {
    if (this._isEnabled()) {
      return this.props.onNext();
    }
  },

  _addEmptyIngredient() {
    if (this._anyAreEditing()) {
      return;
    }

    return store.dispatch({
      type: 'add-ingredient'
    });
  },

  _ingredientAdder(index) {
    return (rawText, tag) => {
      return store.dispatch({
        type: 'commit-ingredient',
        index,
        rawText,
        tag
      });
    };
  },

  _ingredientDeleter(index) {
    return () => {
      return store.dispatch({
        type: 'delete-ingredient',
        index
      });
    };
  }
});



function __guard__(value, transform) {
  return typeof value !== 'undefined' && value !== null ? transform(value) : undefined;
}

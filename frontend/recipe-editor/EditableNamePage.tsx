import {} from 'lodash';
const React = require('react');
const classnames = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const store = require('../store');

const ReduxMixin = require('../mixins/ReduxMixin');

const EditableRecipePage = require('./EditableRecipePage');

const EditableNamePage = React.createClass({
  displayName: 'EditableNamePage',

  mixins: [ReduxMixin({
    editableRecipe: 'name'
  }), PureRenderMixin],

  propTypes: {
    onClose: React.PropTypes.func.isRequired,
    onNext: React.PropTypes.func,
    onPrevious: React.PropTypes.func,
    previousTitle: React.PropTypes.string
  },

  render() {
    return <EditableRecipePage className='name-page' onClose={this.props.onClose} onPrevious={this.props.onPrevious} previousTitle={this.props.previousTitle}><div className='fixed-content-pane'><div className='page-title'>Add a Recipe</div><input type='text' placeholder='Name...' autoCorrect='off' autoCapitalize='on' autoComplete='off' spellCheck='false' ref='input' value={this.state.name} onChange={this._onChange} onTouchTap={this._focus} /><div className={classnames('next-button', { 'disabled': !this._isEnabled() })} onTouchTap={this._nextIfEnabled}><span className='next-text'>Next</span><i className='fa fa-arrow-right' /></div></div></EditableRecipePage>;
  },

  _focus() {
    return this.refs.input.focus();
  },

  // mixin-ify this kind of stuff probably
  _isEnabled() {
    return !!this.state.name;
  },

  _nextIfEnabled() {
    if (this._isEnabled()) {
      store.dispatch({
        type: 'set-name',
        name: this.state.name.trim()
      });
      return this.props.onNext();
    }
  },

  _onChange(e) {
    return store.dispatch({
      type: 'set-name',
      name: e.target.value
    });
  }
});

module.exports = EditableNamePage;

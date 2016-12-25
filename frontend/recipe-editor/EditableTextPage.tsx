import * as React from 'react';
import * as classNames from 'classnames';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import store from '../store';

import ReduxMixin from '../mixins/ReduxMixin';

import EditableRecipePage from './EditableRecipePage';

export default React.createClass({
  displayName: 'EditableTextPage',

  mixins: [ReduxMixin({
    editableRecipe: ['instructions', 'notes']
  })],

  propTypes: {
    onClose: React.PropTypes.func.isRequired,
    onNext: React.PropTypes.func,
    onPrevious: React.PropTypes.func,
    previousTitle: React.PropTypes.string
  },

  render() {
    return <EditableRecipePage className='text-page' onClose={this.props.onClose} onPrevious={this.props.onPrevious} previousTitle={this.props.previousTitle}><div className='fixed-content-pane'><textarea className='editable-text-area' placeholder='Instructions...' onChange={this._setInstructions} value={this.state.instructions} ref='instructions' /><textarea className='editable-text-area' placeholder='Notes (optional)...' onChange={this._setNotes} value={this.state.notes} ref='notes' /><div className={classNames('next-button', { 'disabled': !this._isEnabled() })} onClick={this._nextIfEnabled}><span className='next-text'>Next</span><i className='fa fa-arrow-right' /></div></div></EditableRecipePage>;
  },

  _isEnabled() {
    return this.state.instructions.length;
  },

  _nextIfEnabled() {
    if (this._isEnabled()) {
      return this.props.onNext();
    }
  },

  _setInstructions(e) {
    return store.dispatch({
      type: 'set-instructions',
      instructions: e.target.value
    });
  },

  _setNotes(e) {
    return store.dispatch({
      type: 'set-notes',
      notes: e.target.value
    });
  }
});



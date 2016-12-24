import {} from 'lodash';
const React = require('react');
const classnames = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const store = require('../store');

const ReduxMixin = require('../mixins/ReduxMixin');

const definitions = require('../../shared/definitions');

const List = require('../components/List');

const EditableRecipePage = require('./EditableRecipePage');

const EditableBaseLiquorPage = React.createClass({
  displayName: 'EditableBaseLiquorPage',

  mixins: [ReduxMixin({
    editableRecipe: 'base'
  }), PureRenderMixin],

  propTypes: {
    onClose: React.PropTypes.func.isRequired,
    onNext: React.PropTypes.func,
    onPrevious: React.PropTypes.func,
    previousTitle: React.PropTypes.string
  },

  render() {
    return <EditableRecipePage className='base-tag-page' onClose={this.props.onClose} onPrevious={this.props.onPrevious} previousTitle={this.props.previousTitle}><div className='fixed-content-pane'><div className='page-title'>Base ingredient(s)</div><List>{_.map(definitions.BASE_LIQUORS, tag => {
            return <List.Item className={classnames('base-liquor-option', { 'is-selected': this.state.base.includes(tag) })} onTouchTap={this._tagToggler(tag)} key={`tag-${ tag }`}>{definitions.BASE_TITLES_BY_TAG[tag]}<i className='fa fa-check-circle' /></List.Item>;
          })}</List><div className={classnames('next-button', { 'disabled': !this._isEnabled() })} onTouchTap={this._nextIfEnabled}><span className='next-text'>Next</span><i className='fa fa-arrow-right' /></div></div></EditableRecipePage>;
  },

  _isEnabled() {
    return this.state.base.length > 0;
  },

  _nextIfEnabled() {
    if (this._isEnabled()) {
      return this.props.onNext();
    }
  },

  _tagToggler(tag) {
    return () => {
      return store.dispatch({
        type: 'toggle-base-liquor-tag',
        tag
      });
    };
  }
});

module.exports = EditableBaseLiquorPage;

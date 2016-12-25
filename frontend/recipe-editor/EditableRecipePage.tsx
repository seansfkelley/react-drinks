import * as React from 'react';
import * as classNames from 'classnames';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import store from '../store';

const NavigationHeader = React.createClass({
  displayName: 'NavigationHeader',

  propTypes: {
    onClose: React.PropTypes.func.isRequired,
    previousTitle: React.PropTypes.string,
    onPrevious: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  render() {
    return <div className='navigation-header fixed-header'>{this.props.previousTitle && this.props.onPrevious ? <div className='back-button float-left' onClick={this.props.onPrevious}><i className='fa fa-chevron-left' /><span className='back-button-label'>{this.props.previousTitle}</span></div> : undefined}<i className='fa fa-times float-right' onClick={this._close} /></div>;
  },

  _close() {
    store.dispatch({
      type: 'clear-editable-recipe'
    });

    return this.props.onClose();
  }
});

export default React.createClass({
  displayName: 'EditableRecipePage',

  propTypes: {
    onClose: React.PropTypes.func.isRequired,
    onPrevious: React.PropTypes.func,
    previousTitle: React.PropTypes.string,
    className: React.PropTypes.string
  },

  render() {
    return <div className={classNames('editable-recipe-page fixed-header-footer', this.props.className)}><NavigationHeader onClose={this.props.onClose} previousTitle={this.props.previousTitle} onPrevious={this.props.onPrevious} />{this.props.children}</div>;
  }
});



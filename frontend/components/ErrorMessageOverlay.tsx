import * as React from 'react';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';
import * as classNames from 'classnames';

import ReduxMixin from '../mixins/ReduxMixin';

interface State {
  errorMessage?: any;
}

export default React.createClass<void, State>({
  displayName: 'ErrorMessageOverlay',

  mixins: [
    ReduxMixin({
      ui: 'errorMessage'
    }),
    PureRenderMixin
  ],

  render() {
    let content;
    if (!this.state.errorMessage) {
      content = null;
    } else {
      content = (
        <div className='error-message'>
          <i className='fa fa-exclamation-circle' />
          <div className='message-text'>{this.state.errorMessage}</div>
        </div>
      );
    }

    return (
      <div className={classNames('error-message-overlay', { 'visible': this.state.errorMessage })}>
        {content}
      </div>
    );
  }
});

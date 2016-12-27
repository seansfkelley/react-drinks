import * as React from 'react';
import * as classNames from 'classnames';

import { connect } from 'react-redux';
import { RootState } from '../store';

interface ConnectedProps {
  errorMessage?: string;
}

class ErrorMessageOverlay extends React.PureComponent<ConnectedProps, void> {
  render() {
    let content;
    if (!this.props.errorMessage) {
      content = null;
    } else {
      content = (
        <div className='error-message'>
          <i className='fa fa-exclamation-circle' />
          <div className='message-text'>{this.props.errorMessage}</div>
        </div>
      );
    }

    return (
      <div className={classNames('error-message-overlay', { 'visible': !!this.props.errorMessage })}>
        {content}
      </div>
    );
  }
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    errorMessage: state.ui.errorMessage
  };
}

export default connect(mapStateToProps)(ErrorMessageOverlay) as React.ComponentClass<void>;

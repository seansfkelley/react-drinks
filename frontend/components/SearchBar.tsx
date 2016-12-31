import * as React from 'react';
import * as classNames from 'classnames';

interface Props {
  onChange?: (value: string) => void;
  onFocusChange?: (isFocused: boolean) => void;
  initialValue?: string;
  value?: string;
  placeholder?: string;
  className?: string;
}

interface State {
  value: string;
}

export default class extends React.PureComponent<Props, State> {
  private _input: HTMLInputElement;

  state: State = {
    value: this.props.value || this.props.initialValue || ''
  };

  render() {
    return (
      <div
        className={classNames('search-bar', this.props.className)}
        // onTouchStart={this._stopTouchStart}
      >
        <div className='rounded-border-wrapper'>
          <i className='fa fa-search' />
          <input
            type='text'
            className='search-input'
            placeholder={this.props.placeholder}
            value={this.state.value}
            onChange={this._onChange}
            onClick={this._focus}
            ref={e => this._input = e}
            tabIndex={-1}
            autoCorrect='off'
            autoCapitalize='off'
            autoComplete='off'
            spellCheck={false}
            onFocus={this._makeOnFocusChange(true)}
            onBlur={this._makeOnFocusChange(false)}
          />
          {this.state.value.length
            ? <i
                className='fa fa-times-circle'
                onClick={this._tryClearAndFocus}
                // onTouchStart={this._stopTouchStart}
              />
            : null}
        </div>
      </div>
    );
  }

  componentWillReceiveProps(nextProps: Props) {
    if (nextProps.value != null) {
      this.setState({ value: nextProps.value });
    }
  }

  private _makeOnFocusChange(isFocused: boolean) {
    if (this.props.onFocusChange) {
      return () => {
        this.props.onFocusChange!(isFocused);
      };
    } else {
      return undefined;
    }
  };

  private _isControlled() {
    return this.props.value != null;
  }

  private _tryClearAndFocus = () => {
    this._trySetValue('');
    this._focus();
  };

  private _focus = () => {
    this._input.focus();
  };

  private _onChange = (e: React.FormEvent<HTMLInputElement>) => {
    this._trySetValue(e.currentTarget.value);
  };

  private _trySetValue(value: string) {
    if (!this._isControlled()) {
      this.setState({ value });
    }
    if (this.props.onChange) {
      this.props.onChange(value);
    }
  }

  // Commenting this out but leaving it around for now. I haven't done enough testing to determine if this is
  // still necessary, but its presence breaks other interactions (not being able to select the search bar).
  // I do not know if this a Chrome emulation bug, or the spec, or what.
  // _stopTouchStart(e: React.TouchEvent<HTMLElement>) {
  //   // This is hacky, but both of these are independently necessary.
  //   // 1. Stop propagation so that the App-level handler doesn't deselect the input on clear.
  //   e.stopPropagation();
  //   // 2. Prevent default so that iOS doesn't reassign the active element and deselect the input.
  //   e.preventDefault();
  // }
}

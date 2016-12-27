import * as React from 'react';
import * as classNames from 'classnames';

interface Props {
  onChange: (value: string) => void;
  initialValue?: string;
  placeholder?: string;
  className?: string;
}

interface State {
  value: string;
}

export default class extends React.PureComponent<Props, State> {
  private _input: HTMLInputElement;

  state: State = {
    value: this.props.initialValue != null ? this.props.initialValue : ''
  };

  render() {
    return (
      <div
        className={classNames('search-bar', this.props.className)}
        // onTouchStart={this._stopTouchStart}
      >
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
        />
        {this.state.value.length
          ? <i
              className='fa fa-times-circle'
              onClick={this._clearAndFocus}
              // onTouchStart={this._stopTouchStart}
            />
          : null}
      </div>
    );
  }

  private _clearAndFocus = () => {
    this._clear();
    this._focus();
  };

  private _clear = () => {
    this.setState({ value: '' });
    this.props.onChange('');
  };

  private _focus = () => {
    this._input.focus();
  };

  public isFocused = () => {
    return document.activeElement === this._input;
  };

  private _onChange = (e: React.FormEvent<HTMLInputElement>) => {
    this.setState({ value: e.currentTarget.value });
    this.props.onChange(e.currentTarget.value);
  };

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

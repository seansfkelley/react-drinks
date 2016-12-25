import * as React from 'react';
import * as Draggable from 'react-draggable';
import * as classNames from 'classnames';

const DELETABLE_WIDTH = 80;

interface Props {
  onDelete: Function;
  className?: string;
}

interface State {
  initialX: number;
  deltaX: number;
  checkFirstMove: boolean;
  ignoreDrag: boolean;
}

export default React.createClass<Props, State>({
  displayName: 'Deletable',

  getInitialState() {
    return {
      initialX: 0,
      deltaX: 0,
      checkFirstMove: true,
      ignoreDrag: false
    };
  },

  render() {
    return (
      <Draggable
        axis='x'
        bounds={{ left: -DELETABLE_WIDTH, right: 0 }}
        onStart={this._onDragStart}
        onDrag={this._onDrag}
        onStop={this._onDragEnd}
        ref='draggable'
      >
        <div className={classNames('deletable', this.props.className)}>
          {this.props.children}
          <div
            className='delete-button'
            style={{ width: Math.abs(this.state.deltaX), right: this.state.deltaX }}
            onClick={this._onDelete}
          >
            <span className='text' style={{ width: DELETABLE_WIDTH }}>
              Delete
            </span>
          </div>
        </div>
      </Draggable>
    );
  },

  _onDelete(event: React.MouseEvent<any>) {
    event.stopPropagation();
    this.props.onDelete();
  },

  _onDragStart(_event: React.MouseEvent<any>, { position }: { position: { left: number } }) {
    // Do NOT reset deltaX -- it may be dragged open already.
    this.setState({ initialX: position.left, checkFirstMove: true, ignoreDrag: false });
  },

  _onDrag(_event: React.MouseEvent<any>, { deltaX, deltaY }: { deltaX: number, deltaY: number }) {
    if (this.state.ignoreDrag) {
      return false;
    } else if (this.state.checkFirstMove && Math.abs(deltaY) > Math.abs(deltaX)) {
      this.setState({ ignoreDrag: true });
      return false;
    } else {
      this.setState({
        deltaX: Math.min(Math.max(this.state.deltaX + deltaX, -DELETABLE_WIDTH), 0) ,
        checkFirstMove: true
      });
      return undefined;
    }
  },

  _onDragEnd(_event: React.MouseEvent<any>) {
    if (this.state.deltaX < -DELETABLE_WIDTH / 2) {
      this.refs.draggable.setState({ clientX: -DELETABLE_WIDTH });
      this.setState({ deltaX: -DELETABLE_WIDTH });
    } else {
      this.refs.draggable.setState({ clientX: 0 });
      this.setState({ deltaX: 0 });
    }
  }
});



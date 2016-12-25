import { isEqual, range, sortedIndex, initial, last } from 'lodash';
import * as React from 'react';
import * as ReactDOM from 'react-dom';
import * as classNames from 'classnames';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import { InertialSwipeLogicBox } from './InertialSwipeLogicBox';

interface InertialSwipableProps {
  itemOffsets: number[];
  onSwiping?: (delta: number) => void;
  onSwiped?: () => void;
  initialDelta?: number;
  getNearestIndex?: (e: React.TouchEvent<void>) => number;
  friction?: number;
  className?: string;
}

const InertialSwipable = React.createClass<InertialSwipableProps, void>({
  displayName: 'InertialSwipable',

  mixins: [PureRenderMixin],

  render() {
    return (
      <div
        onTouchStart={this._onTouchStart}
        onTouchMove={this._onTouchMove}
        onTouchEnd={this._onTouchEnd}
        className={classNames('inertial-swipable', this.props.className)}
      >
        {this.props.children}
      </div>
    );
  },

  _onTouchStart(e: React.TouchEvent<void>) {
    this._logicBox.onTouchStart(e);
  },

  _onTouchMove(e: React.TouchEvent<void>) {
    this._logicBox.onTouchMove(e);
  },

  _onTouchEnd(e: React.TouchEvent<void>) {
    this._logicBox.onTouchEnd(e);
  },

  componentDidMount() {
    this._logicBox = new InertialSwipeLogicBox(
      this.props.itemOffsets,
      this.props.getNearestIndex,
      this.props.onSwiping,
      this.props.onSwiped,
      this.props.friction ? 1 - this.props.friction : undefined,
      this.props.initialDelta
    );
  },

  componentWillReceiveProps(nextProps: InertialSwipableProps) {
    if (!isEqual(nextProps.itemOffsets, this.props.itemOffsets)) {
      if (this._logicBox) {
        this._logicBox.destroy();
      }
      this._logicBox = new InertialSwipeLogicBox(
        nextProps.itemOffsets,
        this.props.getNearestIndex,
        nextProps.onSwiping,
        nextProps.onSwiped,
        this.props.friction ? 1 - this.props.friction : undefined,
        nextProps.initialDelta
      );
    } else if (nextProps.initialDelta !== this.props.initialDelta) {
      if (this._logicBox) {
        this._logicBox.setDeltaInstantly(nextProps.initialDelta);
      }
    }
  },

  componentWillUnmount() {
    if (this._logicBox) {
      this._logicBox.destroy();
    }
  }
});

interface Props {
  initialIndex?: number;
  onSlideChange?: Function;
  friction?: number;
  className?: string;
}

interface State {
  wrapperWidth: number;
  itemWidths: number[];
  itemOffsets: number[];
  delta: number;
  initialDelta: number;
}

export default React.createClass<Props, State>({
  displayName: 'Swipable',

  mixins: [PureRenderMixin],

  getInitialState() {
    const zeroes = range(React.Children.count(this.props.children)).map(() => 0);
    return {
      wrapperWidth: 0,
      itemWidths: zeroes,
      itemOffsets: zeroes,
      delta: 0,
      initialDelta: 0
    };
  },

  _getIndexForDelta(delta: number) {
    // return _.sortedIndex(@state.itemOffsets, delta)
    const shiftedOffsets = range(this.state.itemOffsets.length)
      .map(i => this.state.itemOffsets[i] - this.state.itemWidths[i] / 2);
    // Why is this -1 again?
    return Math.max(0, sortedIndex(shiftedOffsets, delta) - 1);
  },

  render() {
    const offset = -this.state.delta + (this.state.wrapperWidth - this.state.itemWidths[0]) / 2;

    return (
      <InertialSwipable
        onSwiping={this._onSwiping}
        onSwiped={this._onSwiped}
        itemOffsets={this.state.itemOffsets}
        initialDelta={this.state.initialDelta}
        getNearestIndex={this._getNearestIndex}
        friction={this.props.friction}
        className={classNames('viewport-container', this.props.className)}
        ref='inertialSwipable'
      >
        <div
          className='sliding-container'
          ref='slidingContainer'
           style={{
            WebkitTransform: `translateX(${ offset }px) translateZ(0)`, // Hardware acceleration.
            transform: `translateX(${ offset }px)`
          }}
        >
          {this.props.children}
        </div>
      </InertialSwipable>
    );
  },

  componentDidMount() {
    this._computeCachedState();

    window.addEventListener('orientationchange', this._computeCachedState, false);
    window.addEventListener('resize', this._computeCachedState, false);
  },

  componentWillUnmount() {
    window.removeEventListener('orientationchange', this._computeCachedState);
    window.removeEventListener('resize', this._computeCachedState);
  },

  _computeCachedState() {
    const wrapperWidth = this.refs.slidingContainer.offsetWidth;
    const itemWidths: number[] = Array.prototype.slice.apply((this.refs.slidingContainer as HTMLElement).children).map((child: HTMLElement)=> child.offsetWidth);
    const itemOffsets = initial(itemWidths
      .reduce((offsets, width) => { offsets.push(last(offsets) + width); return offsets; }, [ 0 ]));

    const initialDelta = itemOffsets[this.props.initialIndex != null ? this.props.initialIndex : 0];
    this.setState({ wrapperWidth, itemWidths, itemOffsets, initialDelta });
  },

  _getNearestIndex(e: React.TouchEvent<HTMLElement>) {
    // Note that this MUST be `target`, NOT `currentTarget`, as we use event delegation and want the
    // actual element that wat touched, not the delegate listener.
    let target = e.target as HTMLElement;
    while (target != null && target.parentNode !== this.refs.slidingContainer) {
      target = target.parentNode as HTMLElement;
    }
    if (target) {
      return Array.prototype.indexOf.call((this.refs.slidingContainer as HTMLElement).children, target);
    } else {
      const { offsetLeft, offsetWidth } = ReactDOM.findDOMNode(this.refs.inertialSwipable) as HTMLElement;
      if (e.changedTouches[0].clientX - offsetLeft < offsetWidth / 2) {
        return 0;
      } else {
        return this.refs.slidingContainer.children.length - 1;
      }
    }
  },

  _onSwiping(delta: number) {
    const oldIndex = this._getIndexForDelta(this.state.delta);
    const newIndex = this._getIndexForDelta(delta);
    this.setState({ delta });
    if (oldIndex !== newIndex) {
      this.props.onSlideChange(newIndex);
    }
  },

  _onSwiped() {
    // Don't call onSlideChange; we assume the diff between the most recent call of it and now is negligible.
    const index = this._getIndexForDelta(this.state.delta);
    this.setState({ initialDelta: this.state.itemOffsets[index] });
  }
});

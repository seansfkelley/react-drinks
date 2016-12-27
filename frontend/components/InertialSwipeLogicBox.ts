import { assign, first, last, sortedIndex } from 'lodash';
import { assert } from '../../shared/tinyassert';

const TIME_CONSTANT = 150;

enum CaptureType {
  INDETERMINATE = -1,
  NO = 0,
  YES = 1
};

abstract class InertialLogicBoxMembers {
  trueDelta: number = 0;
  visibleDelta: number = 0;
  captureType?: CaptureType;
  initialTouchX?: number;
  initialTouchY?: number;
  lastX?: number;
  lastTrackedTime?: number;
  lastTrackedDelta?: number;
  lastTrackedVelocity?: number;
  animFrame?: number;
  interval?: number;
}

export class InertialSwipeLogicBox extends InertialLogicBoxMembers {
  constructor(
    private itemOffsets: number[],
    private getNearestIndex: (e: React.TouchEvent<HTMLElement>) => number,
    private onChangeDelta?: (delta: number) => void,
    private onFinish?: () => void,
    private amplitudeFactor: number = 0.5,
    initialDelta?: number
  ) {
    super();

    this._set({
      trueDelta: initialDelta != null ? initialDelta : 0,
      visibleDelta: initialDelta != null ? initialDelta : 0,
      captureType: undefined,
      initialTouchX: undefined,
      initialTouchY: undefined,
      lastX: undefined,
      lastTrackedTime: undefined,
      lastTrackedDelta: undefined,
      lastTrackedVelocity: undefined
    });
  }

  onTouchStart(e: React.TouchEvent<HTMLElement>) {
    if (e.touches.length > 1) {
      return;
    }

    if (this.animFrame != null) {
      cancelAnimationFrame(this.animFrame);
    }

    this._set({
      captureType: CaptureType.INDETERMINATE,
      initialTouchX: e.touches[0].clientX,
      initialTouchY: e.touches[0].clientY,
      lastX: e.touches[0].clientX,
      lastTrackedTime: Date.now(),
      lastTrackedDelta: this.visibleDelta,
      lastTrackedVelocity: 0
    });

    this.interval = setInterval(this._trackVelocity.bind(this), 50) as any as number;
  };

  onTouchMove(e: React.TouchEvent<HTMLElement>) {
    if (e.touches.length > 1 || this.captureType === CaptureType.NO) {
      return;
    }

    if (this.captureType === CaptureType.INDETERMINATE) {
      const dx = Math.abs(this.initialTouchX - e.changedTouches[0].clientX);
      const dy = Math.abs(this.initialTouchY - e.changedTouches[0].clientY);
      if (dx < 5) {
        // Jitter, don't do anything yet cause it could be a tap.
        return;
      } else if (dx < dy) {
        // Obviously, this implies we can only swip horizontal. Fine for now.
        this._set({ captureType: CaptureType.NO });
        return;
      } else {
        // Now we're swiping!
        this._set({ captureType: CaptureType.YES });
      }
    }

    // Prevent scrolling: if you drag horizontally and then vertically in one motion, you'll scroll and swipe.
    e.preventDefault();

    const trueDelta = this.trueDelta - (e.changedTouches[0].clientX - this.lastX);
    const visibleDelta = this._computeResistance(trueDelta);

    this._set({
      trueDelta,
      visibleDelta,
      lastX: e.changedTouches[0].clientX
    });
  }

  onTouchEnd(e: React.TouchEvent<HTMLElement>) {
    if (e.touches.length > 1) {
      return;
    }

    clearInterval(this.interval as any as NodeJS.Timer);

    if (this.captureType === CaptureType.NO) {
      this._autoScroll(this.itemOffsets[this.getNearestIndex(e)], 'target');
      return;
    }

    this.onTouchMove(e);
    this._set({
      lastX: undefined,
      lastTrackedTime: undefined,
      lastTrackedDelta: undefined
    });

    const distance = e.changedTouches[0].clientX - this.initialTouchX;
    // Tap, rather than swipe.
    if (Math.abs(distance) < 10) {
      this._autoScroll(this.itemOffsets[this.getNearestIndex(e)], 'target');
    } else {
      this._autoScroll(this.amplitudeFactor * this.lastTrackedVelocity, 'amplitude');
    }
  }

  // TODO: We probably actually want to animate this.
  setDeltaInstantly(delta: number) {
    assert(this._isInRange(delta));

    this._set({
      visibleDelta: delta,
      trueDelta: delta
    });
  }

  _set(fields: Partial<{ [k in keyof InertialLogicBoxMembers]: InertialLogicBoxMembers[k] }>) {
    if (this.onChangeDelta && fields.visibleDelta != null && fields.visibleDelta !== this.visibleDelta) {
      this.onChangeDelta(fields.visibleDelta);
    }

    assign(this, fields);
  }

  _trackVelocity() {
    const now = Date.now();
    const elapsed = now - this.lastTrackedTime;

    const v = 1000 * (this.visibleDelta - this.lastTrackedDelta) / (1 + elapsed);

    this._set({
      lastTrackedTime: now,
      lastTrackedDelta: this.visibleDelta,
      lastTrackedVelocity: 0.8 * v + 0.2 * this.lastTrackedVelocity
    });
  }

  _computeResistance(trueDelta: number) {
    if (trueDelta > last(this.itemOffsets)) {
      const overflow = trueDelta - last(this.itemOffsets);
      return last(this.itemOffsets) + Math.sqrt(overflow) * 4;
    } else if (trueDelta < 0) {
      return -Math.sqrt(Math.abs(trueDelta)) * 4;
    } else {
      return trueDelta;
    }
  }

  _uncomputeResistance(visibleDelta: number) {
    if (visibleDelta > last(this.itemOffsets)) {
      const overflow = visibleDelta - last(this.itemOffsets);
      return last(this.itemOffsets) + Math.pow(overflow / 4, 2);
    } else if (visibleDelta < 0) {
      return -Math.pow(Math.abs(visibleDelta) / 4, 2);
    } else {
      return visibleDelta;
    }
  }

  _isInRange(value: number) {
    return 0 <= value && value <= last(this.itemOffsets);
  }

  _snapToNearestOffset(value: number) {
    const i = sortedIndex(this.itemOffsets, value);
    if (i === 0) {
      return first(this.itemOffsets);
    } else if (i === this.itemOffsets.length) {
      return last(this.itemOffsets);
    } else if (Math.abs(value - this.itemOffsets[i - 1]) < Math.abs(value - this.itemOffsets[i])) {
      return this.itemOffsets[i - 1];
    } else {
      return this.itemOffsets[i];
    }
  }

  _autoScroll(value: number, type: 'amplitude' | 'target') {
    if (!this._isInRange(this.visibleDelta)) {
      this._bounceBackIfNecessary();
      return;
    }

    let target = type === 'target' ? value : this.trueDelta + value;

    if (this._isInRange(target)) {
      target = this._snapToNearestOffset(target);
    }

    const amplitude = target - this.trueDelta;

    return this._animate(
      amplitude,

      (stepDelta: number) => {
        const trueDelta = target + stepDelta;
        const visibleDelta = this._computeResistance(trueDelta);

        if (Math.abs(visibleDelta - this.visibleDelta) < 5 && !this._isInRange(this.visibleDelta)) {
          this._set({ trueDelta, visibleDelta });
          // cancelAnimationFrame?
          delete this.animFrame;
          this._bounceBackIfNecessary();
          return false;
        } else {
          this._set({ trueDelta, visibleDelta });
          return;
        }
      },

      () => {
        this._set({
          trueDelta: target,
          visibleDelta: target
        });
        if (this.onFinish) {
          this.onFinish();
        }
      }
    );
  }

  _bounceBackIfNecessary() {
    let target: number;
    if (this.visibleDelta < 0) {
      target = 0;
    } else if (this.visibleDelta > last(this.itemOffsets)) {
      target = last(this.itemOffsets);
    } else {
      target = this.visibleDelta;
    }

    return this._animate(
      target - this.visibleDelta,

      (stepDelta: number) => {
        const visibleDelta = target + stepDelta;
        const trueDelta = this._uncomputeResistance(visibleDelta);
        this._set({ trueDelta, visibleDelta });
      },

      () => {
        this._set({
          trueDelta: target,
          visibleDelta: target
        });
        if (this.onFinish) {
          this.onFinish();
        }
      }
    );
  }

  _animate(amplitude: number, onStep: (stepDelta: number) => false | void, onFinish?: () => void) {
    const startTime = Date.now();
    const step = () => {
      const elapsed = Date.now() - startTime;
      const stepDelta = -amplitude * Math.exp(-elapsed / TIME_CONSTANT);
      if (stepDelta < -1 || stepDelta > 1) {
        // Must literally return false. Note that this will NOT call onFinish.
        if (onStep(stepDelta) !== false) {
          this.animFrame = requestAnimationFrame(step);
        }
      } else {
        if (onFinish) {
          onFinish();
        }
        delete this.animFrame;
      }
    };

    this.animFrame = requestAnimationFrame(step);
  }

  destroy() {
    cancelAnimationFrame(this.animFrame!);
    clearInterval(this.interval as any as NodeJS.Timer);
  }
}

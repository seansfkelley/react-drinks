import { once } from 'lodash';
import * as Bluebird from 'bluebird';
import * as injectTapEventPlugin from 'react-tap-event-plugin';

export default once(() => {
  Bluebird.longStackTraces();
  injectTapEventPlugin();

  if ((window.navigator as any).standalone) {
    document.body.setAttribute('standalone', 'true');
  }
});

// an attempt to fix https://github.com/zilverline/react-tap-event-plugin/issues/7
//
// if 'ontouchstart' of window
//   kill = (type) ->
//     window.document.addEventListener(type, (e) ->
//       e.preventDefault()
//       e.stopPropagation()
//       return false
//     , true)

//   for type in [ 'mousedown', 'mouseup', 'mousemove', 'click' ]
//     kill type

import { once } from 'lodash';
import * as Bluebird from 'bluebird';

export default once(() => {
  Bluebird.longStackTraces();

  if ((window.navigator as any).standalone) {
    document.body.setAttribute('standalone', 'true');
  }
});

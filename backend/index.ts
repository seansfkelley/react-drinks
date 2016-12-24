import * as log from 'loglevel';

// Logging before all.
log.setLevel('debug');
log.info(`starting spirit guide with PORT=${process.env.PORT} and NODE_ENV=${process.env.NODE_ENV}`);

import * as express from 'express';
import * as notifier from 'node-notifier';
import * as bodyParser from 'body-parser';
import * as morgan from 'morgan';
import * as expressPromise from 'express-promise';

import { assert } from '../shared/tinyassert';
import { ROUTES } from './routes';

export function start() {
  // Express.
  const app = express();

  // Templating.
  app.set('view engine', 'jade');

  // Middleware.
  app.use(bodyParser.urlencoded({ extended: true }));
  app.use(morgan('dev'));
  app.use(expressPromise());

  // Routes.
  app.use('/assets', express.static(__dirname + '/../.dist'));
  log.info(`attaching ${ROUTES.length} routes`);
  ROUTES.forEach(({ method, route, handler }) => {
    log.info(`  ${method.toUpperCase()} ${route}`);
    app[method](route, handler);
  });

  // Go.
  const port = process.env.PORT != null ? process.env.PORT : 8080;
  app.listen(port);
  log.info(`listening on localhost:${port}`);

  return notifier.notify({
    title: 'Server started',
    message: `localhost:${port}`
  });
};


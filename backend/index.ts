const log = require('loglevel');

// Logging before all.
log.setLevel('debug');

log.info(`starting spirit guide with PORT=${ process.env.PORT } and NODE_ENV=${ process.env.NODE_ENV }`);

const _ = require('lodash');
const express = require('express');
const notifier = require('node-notifier');
const assert = require('../shared/tinyassert');

const routes = require('./routes');

const start = function () {
  // Express.
  const app = express();

  // Templating.
  app.set('view engine', 'jade');

  // Middleware.
  app.use(require('body-parser').urlencoded({ extended: true }));
  app.use(require('morgan')('dev'));
  app.use(require('express-promise')());

  // Routes.
  app.use('/assets', express.static(__dirname + '/../.dist'));
  log.info(`attaching ${ routes.length } routes`);
  for (let { method, route, handler } of routes) {
    assert(method);
    assert(route);
    assert(handler);
    log.info(`  ${ method.toUpperCase() } ${ route }`);
    app[method](route, handler);
  }

  // Go.
  const port = process.env.PORT != null ? process.env.PORT : 8080;
  app.listen(port);
  log.info(`listening on localhost:${ port }`);

  return notifier.notify({
    title: 'Server started',
    message: `localhost:${ port }`
  });
};

module.exports = { start };


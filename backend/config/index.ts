let config;
const _ = require('lodash');
const log = require('loglevel');
const fs = require('fs');
const yaml = require('js-yaml');

switch (process.env.NODE_ENV) {
  case 'production':
    log.info('loading config from config-production.yaml');
    config = yaml.safeLoad(fs.readFileSync(`${ __dirname }/config-production.yaml`));
    break;
  case 'staging':
    log.info('loading config from config-staging.yaml');
    config = yaml.safeLoad(fs.readFileSync(`${ __dirname }/config-staging.yaml`));
    break;
  default:
    log.info('loading config from config-development.yaml');
    config = yaml.safeLoad(fs.readFileSync(`${ __dirname }/config-development.yaml`));
}

module.exports = config;


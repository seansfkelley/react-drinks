_    = require 'lodash'
log  = require 'loglevel'
fs   = require 'fs'
yaml = require 'js-yaml'

switch process.env.NODE_ENV
  when 'production'
    log.info 'loading config from config-production.yaml'
    config = yaml.safeLoad fs.readFileSync("#{__dirname}/config-production.yaml")
  when 'staging'
    log.info 'loading config from config-staging.yaml'
    config = yaml.safeLoad fs.readFileSync("#{__dirname}/config-staging.yaml")
  else
    log.info 'loading config from config-development.yaml'
    config = yaml.safeLoad fs.readFileSync("#{__dirname}/config-development.yaml")

module.exports = config

_    = require 'lodash'
log  = require 'loglevel'
fs   = require 'fs'
yaml = require 'js-yaml'

if process.env.NODE_ENV == 'production'
  log.info 'loading config from config-production.yaml'
  config = yaml.safeLoad fs.readFileSync("#{__dirname}/config-production.yaml")
else
  log.info 'loading config from config-development.yaml'
  config = yaml.safeLoad fs.readFileSync("#{__dirname}/config-development.yaml")

module.exports = config

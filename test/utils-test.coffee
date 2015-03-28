require('loglevel').setLevel 'silent'

_      = require 'lodash'
should = require('chai').should()

utils = require '../frontend/utils'

describe 'utils', ->
  describe '#splitMeasure', ->
    GOOD_TEST_CASES = [
      input  : undefined
      output :
        unit : ''
    ,
      input  : ''
      output :
        unit : ''
    ,
      input  : '1 ounce'
      output :
        measure : '1'
        unit    : 'ounce'
    ,
      input  : '1/2 ounce'
      output :
        measure : '1/2'
        unit    : 'ounce'
    ,
      input  : '1 1/2 ounce'
      output :
        measure : '1 1/2'
        unit    : 'ounce'
    ,
      input  : '1-2 dashes'
      output :
        measure : '1-2'
        unit    : 'dashes'
    ,
      input  : '1/2 - 1 scoops'
      output :
        measure : '1/2 - 1'
        unit    : 'scoops'
    ,
      input  : '1 - 1 1/2 scoops'
      output :
        measure : '1 - 1 1/2'
        unit    : 'scoops'
    ]

    BAD_TEST_CASES = [
      input  : '1 to 2 dashes'
      output :
        measure : '1'
        unit    : 'to 2 dashes'
    ]

    ALL_TEST_CASES = GOOD_TEST_CASES.concat(BAD_TEST_CASES)

    _.each ALL_TEST_CASES, ({ input, output }) ->
      { unit, measure } = output
      outputString = ('{ ' +
        _.compact([
          if measure? then "measure : #{JSON.stringify measure}"
          if unit? then "unit : #{JSON.stringify unit}"
        ]).join(', ') +
      ' }').replace(/\s+/g, ' ')
      it "should return #{outputString} for input #{JSON.stringify input}", ->
        utils.splitMeasure(input).should.deep.equal output

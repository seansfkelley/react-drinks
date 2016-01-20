_ = require 'lodash'

utils = require '../frontend/utils'

describe 'utils', ->
  describe '#parseIngredientFromText', ->
    AMOUNTS_AND_UNITS = [
      input  : '1 ounce'
      output :
        displayAmount : '1'
        displayUnit   : 'ounce'
    ,
      input  : '1/2 ounce'
      output :
        displayAmount : '1/2'
        displayUnit   : 'ounce'
    ,
      input  : '1 1/2 ounce'
      output :
        displayAmount : '1 1/2'
        displayUnit   : 'ounce'
    ,
      input  : '1-2 dashes'
      output :
        displayAmount : '1-2'
        displayUnit   : 'dashes'
    ,
      input  : '1/2 - 1 scoops'
      output :
        displayAmount : '1/2 - 1'
        displayUnit   : 'scoops'
    ,
      input  : '1 - 1 1/2 scoops'
      output :
        displayAmount : '1 - 1 1/2'
        displayUnit   : 'scoops'
    ]

    GOOD_TEST_CASES = [
      input  : undefined
      output : {}
    ,
      input  : ''
      output : {}
    ,
      input  : '1'
      output :
        displayAmount : '1'
    ,
      input  : '1 ingredient'
      output :
        displayAmount     : '1'
        displayIngredient : 'ingredient'
    ,
      input  : 'ingredient'
      output :
        displayIngredient : 'ingredient'
    ]
    .concat AMOUNTS_AND_UNITS
    .concat _.map AMOUNTS_AND_UNITS, ({ input, output }) -> {
      input  : "#{input} ingredient"
      output : _.extend {
        displayIngredient : 'ingredient'
      }, output
    }

    BAD_TEST_CASES = [
      input  : '1 to 2 dashes'
      output :
        displayAmount     : '1'
        displayIngredient : 'to 2 dashes'
    ]

    ALL_TEST_CASES = GOOD_TEST_CASES.concat(BAD_TEST_CASES)

    _.each ALL_TEST_CASES, ({ input, output }) ->
      { displayUnit, displayAmount, displayIngredient } = output
      outputString = ('{ ' +
        _.compact([
          if displayAmount? then "displayAmount : #{JSON.stringify displayAmount}"
          if displayUnit? then "displayUnit : #{JSON.stringify displayUnit}"
          if displayIngredient? then "displayIngredient : #{JSON.stringify displayIngredient}"
        ]).join(', ') +
      ' }').replace(/\s+/g, ' ')
      it "should return #{outputString} for input #{JSON.stringify input}", ->
        utils.parseIngredientFromText(input).should.deep.equal output

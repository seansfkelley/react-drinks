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

  describe '#parsePartialRecipeFromText', ->
    TEST_CASES = [
      name   : 'should return an empty object if given undefined'
      input  : undefined
      output : {}
    ,
      name   : 'should return an empty object if given a string of only whitespace'
      input  : '''
        \t
      '''
      output : {}
    ,
      name   : 'should parse the name from the first \\n\\n-separated block'
      input  : '''
        Name
      '''
      output :
        name : 'Name'
    ,
      name   : 'should parse no name if the text starts with \\n\\n'
      input  : '''


        ingredient
      '''
      output :
        ingredients : [
          { displayIngredient : 'ingredient' }
        ]
    ,
      name   : 'should remove extraneous whitespace between words in the name'
      input  : '''
        This  Is \t A
        Name
      '''
      output :
        name : 'This Is A Name'
    ,
      name   : 'should capitalilize each whitespace-separated-word in the name'
      input  : '''
        this  is \t a
        name
      '''
      output :
        name : 'This Is A Name'
    ,
      name   : 'should trim whitespace from the name'
      input  : '''
        \tName\t

      '''
      output :
        name : 'Name'
    ,
      name   : 'should parse the ingredients, one per line, from the second \\n\\n-separated block'
      input  : '''
        Name

        1 ounce something
        2 somethings
      '''
      output :
        name        : 'Name'
        ingredients : [
          { displayAmount : '1', displayUnit : 'ounce', displayIngredient : 'something' }
          { displayAmount : '2', displayIngredient : 'somethings' }
        ]
    ,
      name   : 'should parse the instructions, preserving single newlines, from the third \\n\\n-separated block'
      input  : '''
        Name

        something

        foo
        bar
      '''
      output :
        name         : 'Name'
        ingredients  : [
          { displayIngredient : 'something' }
        ]
        instructions : 'foo\nbar'
    ,
      name   : 'should trim whitespace from the instructions'
      input  : '''
        Name

        something

        \tfoo
        bar\t
      '''
      output :
        name         : 'Name'
        ingredients  : [
          { displayIngredient : 'something' }
        ]
        instructions : 'foo\nbar'
    ,
      name   : 'should parse the notes from the fourth \\n\\n-separated block'
      input  : '''
        Name

        something

        foo

        bar
      '''
      output :
        name         : 'Name'
        ingredients  : [
          { displayIngredient : 'something' }
        ]
        instructions : 'foo'
        notes        : 'bar'
    ,
      name   : 'should not include anything beyond the fourth \\n\\n-separated block in the notes'
      input  : '''
        Name

        something

        foo

        bar

        there's
        all

        kinds kinds of stuff

        down here
      '''
      output :
        name         : 'Name'
        ingredients  : [
          { displayIngredient : 'something' }
        ]
        instructions : 'foo'
        notes        : 'bar'
    ]

    _.each TEST_CASES, ({ name, input, output }) ->
      it name, ->
        utils.parsePartialRecipeFromText(input).should.deep.equal output

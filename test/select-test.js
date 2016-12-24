select = require '../frontend/store/derived/select'

describe 'select', ->
  it 'should shallowly select non-primitive items', ->
    obj = {}
    arr = []
    result = select({
      one : obj
      two : arr
    }, {
      a : 'one'
      b : 'two'
    })
    result.should.have.property 'a', obj
    result.should.have.property 'b', arr

  it 'should select nested properties using a dot-separated syntax', ->
    select({
      top :
        middle :
          bottom : 1337
    }, {
      value : 'top.middle.bottom'
    }).should.deep.equal {
      value : 1337
    }

  it 'should select multiple values from the same source field', ->
    field = {
      one   : 1
      two   : 2
      three :
        nested : 'stuff'
    }
    select({ field }, {
      everything   : 'field'
      number       : 'field.one'
      deeplyNested : 'field.three.nested'
    }).should.deep.equal {
      everything   : field
      number       : 1
      deeplyNested : 'stuff'
    }

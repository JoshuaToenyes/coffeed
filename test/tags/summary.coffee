_           = require 'lodash'
expect      = (require 'chai').expect
parser      = require './../../dist/parser'

describe '@summary', ->

  afterEach ->
    parser.reset()

  it 'sets the summary on an @class tag', (done) ->
    parser.parse './test/input/0004.coffee', (r) ->
      expect(r.classes.MyClass1).not.to.be.undefined
      expect(r.classes.MyClass1.summary).to.equal 'MyClass1 summary.'
      done()

  it 'overrides the default @class tag summary', (done) ->
    parser.parse './test/input/0004.coffee', (r) ->
      expect(r.classes.MyClass2).not.to.be.undefined
      expect(r.classes.MyClass2.summary).to.equal(
        'Overridden MyClass2 summary.')
      expect(r.classes.MyClass3).not.to.be.undefined
      expect(r.classes.MyClass3.summary).to.equal(
        'Overridden MyClass3 summary.')
      done()

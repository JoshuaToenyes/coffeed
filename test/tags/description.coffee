_           = require 'lodash'
expect      = (require 'chai').expect
parser      = require './../../dist/parser'

describe '@description', ->

  afterEach ->
    parser.reset()

  it 'sets the description on an @class tag', (done) ->
    parser.parse './test/input/0004.coffee', (r) ->
      expect(r.classes.MyClass1).not.to.be.undefined
      expect(r.classes.MyClass1.description).to.equal 'MyClass1 description.'
      done()

  it 'overrides the default @class tag description', (done) ->
    parser.parse './test/input/0004.coffee', (r) ->
      expect(r.classes.MyClass2).not.to.be.undefined
      expect(r.classes.MyClass2.description).to.equal(
        'Overridden MyClass2 description.')
      expect(r.classes.MyClass3).not.to.be.undefined
      expect(r.classes.MyClass3.description).to.equal(
        'Overridden MyClass3 description.')
      done()

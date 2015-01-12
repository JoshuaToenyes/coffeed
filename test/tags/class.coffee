_           = require 'lodash'
expect      = (require 'chai').expect
parser      = require './../../dist/parser'

describe '@class', ->

  afterEach ->
    parser.reset()

  it 'has extends modifier', (done) ->
    parser.parse './test/input/0003.coffee', (r) ->
      expect(r.classes.MyClass).not.to.be.undefined
      c = r.classes.MyClass
      expect(c.props.extends).to.equal 'SomeOtherClass'
      done()

  it 'has author modifier', (done) ->
    parser.parse './test/input/0001.coffee', (r) ->
      expect(r.classes.MyClass).not.to.be.undefined
      c = r.classes.MyClass
      expect(c.props.author).to.equal 'Test Author <test@xyz.com>'
      expect(c.props.version).to.equal '2.0.0'
      done()

  it 'has version modifier', (done) ->
    parser.parse './test/input/0001.coffee', (r) ->
      expect(r.classes.MyClass).not.to.be.undefined
      c = r.classes.MyClass
      expect(c.props.version).to.equal '2.0.0'
      done()

  it 'parses multiple classes', (done) ->
    parser.parse './test/input/0002.coffee', (r) ->
      expect(r.classes.MyClass0).not.to.be.undefined
      expect(r.classes.MyClass1).not.to.be.undefined
      expect(r.classes.MyClass2).not.to.be.undefined
      expect(r.classes.MyClass3).not.to.be.undefined
      cs = r.classes
      expect(cs.MyClass0.props.author).to.equal 'Test Author 0 <test@xyz.com>'
      expect(cs.MyClass0.props.version).to.equal '2.0.0'
      expect(cs.MyClass1.props.author).to.be.undefined
      expect(cs.MyClass1.props.version).to.equal '4.0.0'
      expect(cs.MyClass2.props.author).to.equal 'Test Author 2 <test@xyz.com>'
      expect(cs.MyClass2.props.version).to.be.undefined
      expect(cs.MyClass3.props.author).to.be.undefined
      expect(cs.MyClass3.props.version).to.be.undefined
      done()

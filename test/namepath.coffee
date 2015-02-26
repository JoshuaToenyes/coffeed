_        = require 'lodash'
expect   = (require 'chai').expect
namepath = require './../dist/namepath'


describe.only 'Type Lexer', ->

  it 'should lex!', ->
    t = namepath.parse 'MyModule/AnotherModule/Class::Static<Type<number, string>, string>'
    console.log t
    console.log t.toString()

    t = namepath.parse 'Class'
    console.log t.toString()

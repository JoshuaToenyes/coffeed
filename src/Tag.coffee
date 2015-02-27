##
# Defines the Tag class.
#
# @fileoverview

module.exports = class Tag

  constructor: (@tagName, @content = '') ->
    @typed = tags[@tagName].typed
    if @typed then @parseTypes()
    @named = tags[@tagName].named
    if @named then @parseName()


  parseTypes: ->
    r = regexps.typeSnippet('g')
    m = r.exec @content
    @types = []
    if m
      m = m[1]
      @content = @content.substring r.lastIndex
      ts = m.split '|'
      for t in ts
        @types.push new Type t


  parseName: ->
    r = regexps.nameSnippet('g')
    m = r.exec @content
    @name = ''
    if m
      @name = m[1]
      @content = @content.substring r.lastIndex
    debugger

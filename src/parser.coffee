_         = require 'lodash'
fs        = require 'fs'
_str      = require 'underscore.string'
async     = require 'async'
errors    = require './errors'
warnings  = require './warnings'
tags      = require './tags'
regexps   = require './regexps'
languages = require './languages'
helpers   = require './helpers'
coffee    = require 'coffee-script'
namepath  = require './namepath'

tagsByType = (type) ->
  _.pick tags, (t) -> t.type is type

blockTags       = tagsByType 'block'
memberTags      = tagsByType 'member'
modifierTags    = tagsByType 'modifier'
additionalTags  = tagsByType 'additional'
accessTags      = tagsByType 'access'


isBlock = (segment) ->
  c = helpers.countTags(segment.doclet, blockTags)
  if c > 1 then errors.multipleBlocks(segments)
  return c is 1


isMember = (segment) ->
  helpers.countTags(segment.doclet, memberTags) > 0


classify = (segment) ->
  if isBlock(segment)
    return 'block'
  else if isMember(segment)
    return 'member'
  else
    return 'unknown'





class Target
  constructor: (@path) ->
    @lang     = languages.detect path
    @content  = ''
    @segments = []


class Segment
  constructor: (@target, @raw, @sequence, @line) ->
    r = regexps(@target.lang).segment()
    q = regexps(@target.lang).doclet()
    @raw      = helpers.cleanSegment @raw
    @doclet   = (r.regexp.exec raw)[r.i]
    @code     = raw.substring(r.regexp.lastIndex)
    doclines  = helpers.countLines @doclet
    codelines = helpers.countLeadingLines(@code)
    @codeLine = @line + doclines + codelines + 1
    @unknown  = false
    @ignore   = false
    @codeLine = @line + helpers.countLines(@doclet)
    @doclet   = @doclet.replace q.regexp, ''
    #nodes = coffee.nodes(@code).expressions[0]



class Type

  constructor: (type) ->




class Tag

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




class Doc

  constructor: (segment) ->
    d = regexps.description(tags).exec segment.doclet
    @description = if d? then d[0] else ''
    s = regexps.summary().exec @description
    @summary = if s? then s[0] else ''
    @tags = @containedTags(segment)

  containedTags: (segment) ->
    r = regexps.tagSnippet(tags)
    ts = []
    while t = r.exec(segment.doclet)
      tagName = (_str.clean t[1]).substr 1
      tagContent = _str.clean t[2]
      tag = new Tag tagName, tagContent
      ts.push tag
    ts






module.exports = parser =


  setup: (path, cb) ->
    cb.call null, null, new Target(path)


  read: (target, cb) ->
    fs.readFile target.path, 'utf-8', (err, data) ->
      target.content = data
      cb.call null, err, target


  segment: (target, cb) ->
    r = regexps(target.lang).segment()
    idxs = []
    while match = r.regexp.exec target.content
      idxs.push match.index
    idxs.push target.content.length
    for i in [0...idxs.length - 1]
      raw = target.content.substring idxs[i], idxs[i+1]
      previous = target.content.substring 0, idxs[i]
      previousLines = helpers.countLines(previous)
      leadingLines = helpers.countLeadingLines(raw)
      segmentLine = previousLines + leadingLines + 1
      segment = new Segment target, raw, i, segmentLine
      target.segments.push segment
    cb.call null, null, target


  process: (target, cb) ->
    _.each target.segments, (segment) ->
      segment.doc = new Doc segment
      if classify(segment) is 'unknown'
        if segment.sequence is 0
          warnings.implicitFileOverview(segment)
          segment.doc.tags.push new Tag('fileoverview')
        else
          warnings.unknownDoclet(segment)
          segment.unknown = true
    cb.call null, null, target


  parse: (path, done) ->
    async.waterfall [
      (cb) -> parser.setup(path, cb)
      parser.read
      parser.segment
      parser.process
    ], (err, result) ->
      done.call null, err, result

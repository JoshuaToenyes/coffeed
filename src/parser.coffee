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
Doc       = require './Doc'
Tag       = require './Tag'


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




module.exports = parser =

  ##
  # Performs initial setup tasks before parsing a target.
  #
  # @param {string} path - The path to the target file.
  #
  # @param {function} cb - The callback function.
  #
  # @private

  setup: (path, cb) ->
    cb.call null, null, new Target(path)


  ##
  # Reads the file specified by the passed Target.
  #
  # @param {Target} target - The parsing target.
  #
  # @param {function} cb - Callback function.
  #
  # @private

  read: (target, cb) ->
    fs.readFile target.path, 'utf-8', (err, data) ->
      target.content = data
      cb.call null, err, target


  ##
  # Segments the passed target into documentation segments.
  #
  # @param {Target} target - The parsing target.
  #
  # @param {function} cb - Callback function.
  #
  # @private

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


  ##
  # Processes the documentation segments in the passed parse target.
  #
  # @param {Target} target - The parsing target.
  #
  # @param {function} cb - Callback function.
  #
  # @private

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


  ##
  # Parses the documentation for the passed file path.
  #
  # @param {string} path - Path to file to document.
  #
  # @param {function} done - Callback function.
  #
  # @public

  parse: (path, done) ->
    async.waterfall [
      (cb) -> parser.setup(path, cb)
      parser.read
      parser.segment
      parser.process
    ], (err, result) ->
      done.call null, err, result

##
# Defines the Segment class.
#
# @fileoverview
#
# @requires coffee-script
# @requires lodash
# @requires underscore.string

_         = require 'lodash'
_str      = require 'underscore.string'
CodeBlock = require './CodeBlock'
coffee    = require 'coffee-script'
DocBlock  = require './DocBlock'
helpers   = require './helpers'
regexps   = require './regexps'


##
# Cleans the raw segment text by removing extra newlines and un-indenting the
# text.
#
# @param {string} content - Raw segment content string to clean.
#
# @returns {string} - The cleaned segment contents.
#
# @function
# @private
#
# @todo Check if this works with strangly indented blocks... that is, with
# varying indentation. I don't think it will.

cleanSegment = (content) ->
  content = content.replace /^\n+/g, ''
  spc = 0
  i = 0
  clean = []
  while content.charAt(i++) is ' '
    spc++
  _.each _str.lines(content), (l) ->
    clean.push l.substring(spc)
  clean = clean.join '\n'
  _str.trim clean


##
# Represents a document segment, which consists of a pair of documentation and
# it's associated code.
#
# @class Segment

module.exports = class Segment


  ##
  # Creates a new Segment, instantiating it's associated DocBlock and
  # CodeBlocks.
  #
  # @param {Target} target    - Associated target stream.
  # @param {string} raw       - The raw string contents of this Segment.
  # @param {number} sequence  - The sequence number of this segment within the
  #                             target.
  # @param {number} line      - The line at-which this segment begins.
  #
  # @constructor

  constructor: (@target, @raw, @sequence, line) ->

    # RegExp to separate documentation content from code content.
    r = regexps(@target.lang).segment()

    # RegExp to remove leading line comment markers on doc block.
    q = regexps(@target.lang).docBlock()

    # Clean the raw segment content.
    @raw  = cleanSegment @raw

    # Pull the documentation content from the raw segment.
    docContent = (r.regexp.exec @raw)[r.i]
    docContent = docContent.replace q.regexp, ''

    # Instantiate the DocBlock for this segment.
    @doc = new DocBlock docContent, line

    # Pull the code content starting from where the doc content stops.
    codeContent = @raw.substring(r.regexp.lastIndex)

    # Calculate the line number where the code starts.
    leadingCodeLines = helpers.countLeadingLines codeContent
    codeLine = line + @doc.lineCount + leadingCodeLines + 1

    # Instantiate the CodeBlocks
    @code = new CodeBlock codeContent, codeLine

    @unknown  = false
    @ignore   = false

    #nodes = coffee.nodes(@code).expressions[0]

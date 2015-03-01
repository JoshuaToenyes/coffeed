##
# Defines the DocBlock class, which represents the documentation portion of
# a parsed segment.

_       = require 'lodash'
_str    = require 'underscore.string'
Block   = require './Block'
regexps = require './regexps'
tags    = require './tags'


module.exports = class DocBlock extends Block

  ##
  #
  # @param {string} @contents - String contents of documentation block.
  #
  # @constructor

  constructor: (content, line) ->
    super(content, line)

    # Parse out the leading tag description.
    desc = regexps.description(tags).exec content
    @description = if desc? then desc[0] else ''

    # Parse the block summary.
    summ = regexps.summary().exec @description
    @summary = if summ? then summ[0] else ''

    @tags = DocBlock.parseTags(@content)

    debugger


  ##
  # Parses the tags from the passed Segment.
  #
  # @param {Segment} segment - Parent Segment object from which to parse tags.
  #
  # @returns {Array<Tag>} Array of parsed tags.
  #
  # @private
  # @static

  @parseTags: (content) ->
    r = regexps.tagSnippet(tags)
    ts = []
    while t = r.exec(content)
      tagName = (_str.clean t[1]).substr 1
      tagContent = _str.clean t[2]
      tag = new tags[tagName](tagContent)
      ts.push tag
    ts

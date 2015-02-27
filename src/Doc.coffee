##
# Defines the Doc class.
#
# @fileoverview

_str    = require 'underscore.string'
regexps = require './regexps'
Tag     = require './Tag'


##
# Represents the parsed documentation portion of a Segment.
#
# @class Doc
# @private

module.exports = class Doc

  ##
  # Reads the passed segment, parsing the description, summary, and contained
  # tags.
  #
  # @param {Segment} segment - The parent Segment object for this Doc.
  #
  # @constructor
  #
  # @todo - Remove requirement to pass a segment, and make it work for a plain
  # piece of passed text. Just passing the doclet should be enough.

  constructor: (segment) ->
    d = regexps.description(tags).exec segment.doclet
    @description = if d? then d[0] else ''
    s = regexps.summary().exec @description
    @summary = if s? then s[0] else ''
    @tags = @containedTags(segment)


  ##
  # Parses the tags from the passed Segment.
  #
  # @param {Segment} segment - Parent Segment object from which to parse tags.
  #
  # @returns {Array<Tag>} Array of parsed tags.
  #
  # @private
  #
  # @todo - Remove requirement to pass a segment, and make it work for a plain
  # piece of passed text.

  containedTags: (segment) ->
    r = regexps.tagSnippet(tags)
    ts = []
    while t = r.exec(segment.doclet)
      tagName = (_str.clean t[1]).substr 1
      tagContent = _str.clean t[2]
      tag = new Tag tagName, tagContent
      ts.push tag
    ts

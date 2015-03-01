##
# Defines a generic block within a documentation/code segment.

helpers   = require './helpers'


##
# Represents a generic block within a documentation/code segment.
#
# @class Block
# @abstract

module.exports = class Block

  ##
  #
  # @param {string} @content - String contents of block.
  # @param {number} @line    - Line in target where this block starts.
  #
  # @constructor

  constructor: (@content, @line) ->
    @lineCount = helpers.countLines @content

##
# Defines the CodeBlock class, which represents the code portion of a parsed
# segment.

Block = require './Block'


##
# Represents the code portion of a parsed segment.
#
# @class CodeBlock

module.exports = class CodeBlock extends Block

  ##
  #
  # @param {string} @content - String contents of code block.
  #
  # @constructor

  constructor: (content, line) ->
    super(content, line)

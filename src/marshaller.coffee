##
# Defines the Marshaller, which is responsible for assembling the documentation
# symbols from the parsed segments.
#
# @fileoverview

async   = require 'async'
symbols = require './symbols'


module.exports =

  marshal: (targets = []) ->

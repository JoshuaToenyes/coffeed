languages = require './languages'

module.exports = class Target
  constructor: (@path) ->
    @lang     = languages.detect path
    @content  = ''
    @segments = []

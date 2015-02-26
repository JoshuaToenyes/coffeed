_       = require 'lodash'
helpers = require './helpers'


# This file (within the config/ directory) contains the YAML which defines
# all regular expressions used for parsing documentation.
REGEXP_CONFIG_FILE = 'regexps.yaml'

# Load-up the regular expression strings.
config = helpers.loadConfig REGEXP_CONFIG_FILE

regexps = {}

# Instantiate all the Regexp objects.
for lang, regexps of config
  regexps[lang] = {}
  for item, r of regexps
    regexps[lang][item] = ((r) ->
      ->
        regexp: new RegExp r.regexp, r.flags
        i:      r.i
        j:      r.j
        k:      r.k
    )(r)


joinTags = (tags, postfix = '') ->
  t = _.keys(tags).join("#{postfix}|@")
  "(@#{t}#{postfix})"


# Returns the regular expressions for the passed file extension.
module.exports = (language) ->
  return regexps[language]

# Returns the
module.exports.tags = (tags, flags) ->
  if tags.length is 0 then throw new Error 'No tags passed.'
  new RegExp joinTags(tags), flags


module.exports.description = (tags, flags) ->
  if tags.length is 0 then throw new Error 'No tags passed.'
  tags = joinTags(tags)
  new RegExp "((?!#{tags}).|\n)*", flags


module.exports.summary = ->
  new RegExp '^((.|\n)*?)[.?!]'


module.exports.tagSnippet = (tags, flags = 'g') ->
  tags = joinTags(tags, '\\s')
  new RegExp "#{tags}(((?!#{tags}).|\n)*)", flags


module.exports.typeSnippet = (flags) ->
  new RegExp "{(.*)}", flags


module.exports.nameSnippet = (flags) ->
  new RegExp "(\\w+)(\\s|\\-)*", flags

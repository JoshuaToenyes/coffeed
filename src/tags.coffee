_       = require 'lodash'
fs      = require 'fs'
path    = require 'path'
yaml    = require 'js-yaml'
helpers = require './helpers'


# This file (within the config/ directory) contains the YAML which defines
# all parsable tag definitions.
TAGS_CONFIG_FILE = 'tags.yaml'


# Try to read the tag definition file.
try
  tagFilePath = path.normalize __dirname + "./../config/#{TAGS_CONFIG_FILE}"
  tagConfig = fs.readFileSync tagFilePath, 'utf8'
catch
  console.error 'Cannot locate or read tag definitions file.'
  process.exit 1


# Try to parse the tag definition YAML.
try
  tagDefinitions = yaml.safeLoad tagConfig
catch
  console.error 'Cannot parse tag definitions file.'
  process.exit 1


##
# Represents a single tag.
#
# @class Tag
# @private

class Tag

  constructor: (@name, def) ->
    @type       = def.type
    @synonyms   = def.synonyms  or []
    @modifiers  = def.modifiers or []
    @values     = def.values    or []
    @content    = helpers.truthy(def.content or 'no')
    @typed      = helpers.truthy(def.typed   or 'no')
    @named      = helpers.truthy(def.named   or 'no')


##
# Array of all Tag classes as parsed from the tag definition file.
#
# @type Array<Tag>
# @private

module.exports = tags = {}


# Iterate through each tag definition and instantiate a Tag class. Also,
# instantiate a Tag instance for each of it's synonyms.
for k, v of tagDefinitions
  t = new Tag k, v
  for s in t.synonyms
    newSynonyms = _.without t.synonyms, k
    st = new Tag s, v
    st.synonyms = _.without t.synonyms, s
    st.synonyms.push k
    tags[s] = st
  tags[k] = t

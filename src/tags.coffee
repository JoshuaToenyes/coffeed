_       = require 'lodash'
fs      = require 'fs'
path    = require 'path'
yaml    = require 'js-yaml'
helpers = require './helpers'


##
# The TagType enum classifies tags into one of several types, which controls
# how the tag is parsed.
#
# @enum {string} TagType
#
# @elem block      - Block tags such as @class and @namespace.
# @elem member     - Member tags such as @method and @function.
# @elem modifier   - Modifier tags such as @field, @var, @elem, etc.
# @elem additional - Additive tags such as @see and @copyright.
# @elem access     - An access modifier tag, @private, @public, etc.


##
# Tag definitions define a tag and how it should be parsed and handled
# throughout the parser and documentation generator.
#
# @struct TagDefinition
#
# @field {TagType} type            - The type of this tag.
# @field {Array<string>} synonyms  - Array of alternative tag names.
# @field {Array<string>} modifiers - List of tags that may modify this tag.
# @field {boolean} content         - If this tag supports the content field.
# @field {boolean} content         - If this tag is typed.
# @field {Array<string>} values    - Array of allowed values.


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

  constructor: (@content) ->


  parse: (@content = '') ->
    if @typed then @parseTypes()
    if @named then @parseName()


  parseTypes: ->
    r = regexps.typeSnippet('g')
    m = r.exec @content
    @types = []
    if m
      m = m[1]
      @content = @content.substring r.lastIndex
      ts = m.split '|'
      for t in ts
        @types.push new Type t


  parseName: ->
    r = regexps.nameSnippet('g')
    m = r.exec @content
    @name = ''
    if m
      @name = m[1]
      @content = @content.substring r.lastIndex


customClasses = {}


parseTagDefinition = (def) ->
  return {
    type:        def.type
    synonyms:    def.synonyms  or []
    modifiers:   def.modifiers or []
    values:      def.values    or []
    content:     helpers.truthy(def.content or 'no')
    typed:       helpers.truthy(def.typed   or 'no')
    named:       helpers.truthy(def.named   or 'no')
  }


##
# Private function which creates a new unique class for the passed tag name
# and tag definition. The newly created class will then be attached to the
# module exports for use throughout the parser. If a class exists with the
# passed tag name, then that class is attached to the module exports. Classes
# are created and named by their primary name in the tags configuration file,
# i.e. tag synonyms do not get their own class.
#
# @param {string} Name - The name of the tag class to create (primary tag name).
#
# @param {Object} definition - The tag definition.
#
# @function createTagClass
# @private
createTagClass = (Name, definition) ->
  name = Name
  if customClasses[Name]?
    module.exports[Name] = Name
  else
    module.exports[Name] = class extends Tag

      @definition: parseTagDefinition(definition)

      constructor: (content) ->
        super(content)
        @name = name


# Iterate through each tag definition and instantiate a Tag class. Also,
# instantiate a Tag instance for each of it's synonyms.
for name, definition of tagDefinitions
  createTagClass name, definition
  definition.synonyms ?= []
  for synonym in definition.synonyms
    module.exports[synonym] = module.exports[name]

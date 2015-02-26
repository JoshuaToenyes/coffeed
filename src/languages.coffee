path    = require 'path'
helpers = require './helpers'


# This file (within the config/ directory) contains the YAML which defines
# all language configuration.
LANG_CONFIG_FILE = 'languages.yaml'


# Load-up the regular expression strings.
langConfig = helpers.loadConfig LANG_CONFIG_FILE


# Map of all extensions -> languages
extensionMap = {}


# Iterate through all language configs and map the extensions.
for lang, def of langConfig
  for extension in def.extensions
    if extensionMap[extension]?
      throw new Error "Extension `#{extension}` declared twice in " +
      "languages.yaml."
    extensionMap[extension] = lang


# Returns the regular expressions for the passed file extension.
module.exports =

  detect: (filepath) ->
    ext = (path.extname filepath).substr(1)
    extensionMap[ext]

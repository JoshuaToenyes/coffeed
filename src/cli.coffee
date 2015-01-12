# ======= Module Dependencies =======

_         = require 'lodash'
_.str     = require 'underscore.string'
chalk     = require 'chalk'
cp        = require 'child_process'
fs        = require 'fs'
mkdirp    = require 'mkdirp'
path      = require 'path'
async     = require 'async'
program   = require 'commander'
parser    = require './parser'

# Currently supported file extensions.
SUPPORTED_FILE_EXTENSIONS = ['.coffee']



processFiles = (filePaths) ->
  for path in filePaths
    parser.parse path



# Takes an array of file names and/or directories and converts it to a list
# of file paths.
parseArgs = (args) ->
  files = []
  parseItem = (item) ->
    item = path.normalize item
    stat = fs.lstatSync(item)
    if stat.isDirectory()
      parseDirectory(item)
    else if path.extname(item) in SUPPORTED_FILE_EXTENSIONS
      files.push(item)
  parseDirectory = (dir) ->
    fs.readdirSync(dir).map (child) -> parseItem(dir + '/' + child)
  for i in args
    parseItem(i)
  files



# ====== CLI Commander Setup ========

program
.version('*|VERSION|*')
.usage('[options] <path ...>')
.option('-d, --debug', 'enable debugging output')
.option('-i, --pid <path>', 'path to pid file')
.parse(process.argv)

processFiles parseArgs program.args

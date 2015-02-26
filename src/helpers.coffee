_       = require 'lodash'
_str    = require 'underscore.string'
fs      = require 'fs'
path    = require 'path'
yaml    = require 'js-yaml'


module.exports = helpers =

  # Loads a YAML configuration file.
  loadConfig: (filename) ->
    try
      filePath = path.normalize __dirname + "./../config/#{filename}"
      raw = fs.readFileSync filePath, 'utf8'
    catch
      console.error "Cannot read config file #{filePath}."
      process.exit 1
    try
      parsed = yaml.safeLoad raw
    catch
      console.error "Cannot parse yaml file #{filePath}."
      process.exit 1
    return parsed


  cleanSegment: (content) ->
    content = content.replace /^\n+/g, ''
    spc = 0
    i = 0
    clean = []
    while content.charAt(i++) is ' '
      spc++
    _.each _str.lines(content), (l) ->
      clean.push l.substring(spc)
    clean = clean.join '\n'
    _str.trim clean

  count: (str, regex) ->
    count = 0
    while regex.exec(str) isnt null
      count++
    count

  countTags: (str, tags) ->
    regexps = require './regexps'
    r = regexps.tags(tags, 'g')
    helpers.count str, r


  countLines: (str) ->
    r = new RegExp '\n', 'g'
    helpers.count str, r


  countLeadingLines: (str) ->
    count = 0
    _.each _str.lines(str), (l) ->
      if _str.trim(l).length is 0 then count++ else return false
    count


  truthy: (s) ->
    s = s.toLowerCase()
    /(yes|true)/.test s


  reverseMap: (m) ->
    nm = {}
    for k, v of m
      nm[v] = k
    nm

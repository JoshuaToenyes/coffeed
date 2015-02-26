_         = require 'lodash'
fs        = require 'fs'
_str      = require 'underscore.string'
helpers   = require './helpers'


BLOCKTYPE_MAP =
  '/':  'module'
  '.':  'namespace'

R_BLOCKTYPE_MAP = helpers.reverseMap BLOCKTYPE_MAP


MEMBERSHIP_MAP =
  '::': 'static'
  '#':  'instance'
  '~':  'inner'

R_MEMBERSHIP_MAP = helpers.reverseMap MEMBERSHIP_MAP


oneLevelSplit = (s, open, close, split) ->
  cs = _str.chars(s)
  ignore = false
  indices = []
  substrings = []
  for c, i in cs
    switch c
      when open then ignore = true
      when close then ignore = false
      when split
        if !ignore then indices.push i + 1
  if indices.length is 0 then return s
  indices.unshift 0
  indices.push s.length
  for i in [0..indices.length - 2]
    sub = _.trim s.substring(indices[i], indices[i + 1])
    if sub[sub.length - 1] is ','
      sub = sub.substring 0, sub.length - 1
    substrings.push sub
  return substrings


splitParameters = (s) ->
  oneLevelSplit s, '<', '>', ','


class Symbol
  constructor: (@name) ->
    @memberof   = null
    @membership = null
    @blocktype  = null
    @parameters = []
    @parameterize()

  parameterize: () ->
    r = /<(.*)>/
    m = r.exec @name
    if m and m[1]
      @name = @name.substring 0, @name.indexOf('<')
      params = splitParameters m[1]
      for p in params
        @parameters.push parse(p)

  toString: ->
    prefix  = if @membership then R_MEMBERSHIP_MAP[@membership] else ''
    postfix = if @blocktype  then R_BLOCKTYPE_MAP[@blocktype] else ''
    if @parameters.length > 0
      sp = []
      for p in @parameters
        sp.push p.toString()
        console.log p, p.toString()
      postfix += '<' + sp.join(', ') + '>'
    a = prefix + @name + postfix
    if @memberof
      return @memberof.toString() + a
    else
      return a



parse = (str) ->
  r = /(~|::|\/|\.|#)/
  np = str.split(r)
  nextMembership = null
  ms = _.reduce _.rest(np), (i, j) ->
    switch j
      when '/' or '.'
        i.blocktype = BLOCKTYPE_MAP[j]
        nextMembership = null
        return i
      when '::' or '#' or '~'
        nextMembership = MEMBERSHIP_MAP[j]
        return i
      else
        t = new Symbol(j)
        t.membership = nextMembership
        t.memberof = i
        return t
  , new Symbol(np[0])


module.exports =

  parse: parse

  oneLevelSplit: oneLevelSplit


_ = require 'lodash'
_str = require 'underscore.string'
fs = require 'fs'
async = require 'async'


documentation = null

currentFile = null
currentTL   = null

# The current scope corresponds to the class, file, module, or namespace
# currently being parsed.
scope = null

# The current member
currentMember = null

#
target = null

# Pushes a new member to the most recently parsed block element (class, module,
# namespace, etc.).
pushMember = (tag, n, t, c, d, s, context) ->
  currentMember =
    tag: tag
    name: n
    content: c
    modifiers: []
    props: {}
  if TAGS[tag].description then currentMember.description = d
  if TAGS[tag].summary then currentMember.summary = s
  if TAGS[tag].typed then currentMember.type = t
  context.members.push currentMember
  target = currentMember

# Pushes a new modifier to the most recently parsed member.
pushModifier = (tag, n, t, c, d, s, context) ->
  m =
    tag: tag
    name: n
    content: c
  if TAGS[tag].typed then m.type = t
  currentMember.modifiers.push m

contentHandler = (tag, n, t, c, d, s, context) ->
  context.props[tag] = c

trueHandler = (tag, n, t, c, d, s, context) ->
  context.props[tag] = true

resetContext = (context) ->
  context.members = []
  context.todos = []
  context.props = {}

TAGS =

  # -- Block Tags --

  # Classes are defined as simply ClassName. If they belong to a module, then
  # they could be shown as module/ClassName. Static members of classes are
  # labeled as ClassName::staticMember, whereas instance members are labeled
  # with a `#` ClassName#instanceMember.
  'class':
    type: 'TL'
    modifiers: 'abstract extends mixes'
    named: true
    handler: (tag, n, t, c, d, s, context) ->
      context.type = 'classes'
      context.name = n
      context.description = d
      context.summary = s
      resetContext(context)

  # Defines a namespace, which are separated by `.` such as window.Object etc.
  'namespace':
    type: 'TL'
    modifiers: 'mixes'
    named: true
    handler: (tag, n, t, c, d, s, context) ->
      context.type = 'namespaces'
      context.name = n
      context.description = d
      context.summary = s
      resetContext(context)

  # Defines a module. Modules are separated by `/` and are shown as
  # myModule/subModule
  'module':
    type: 'TL'
    modifiers: 'mixes'
    named: true
    handler: (tag, n, t, c, d, s, context) ->
      context.type = 'modules'
      context.name = n
      context.description = d
      context.summary = s
      resetContext(context)

  # -- Member Tags --

  'function':
    type: 'MEM'
    synonyms: 'method func constructor'
    modifiers: 'param this returns throws'
    named: true
    description: true
    summary: true
    handler: pushMember

  'property':
    type: 'MEM'
    synonyms: 'prop'
    modifiers: 'setter getter readonly'
    typed: true
    named: true
    handler: pushMember

  'field':
    type: 'MMOD'
    typed: true
    named: true
    handler: pushMember

  'typedef':
    type: 'MEM'
    modifiers: 'param this returns throws property'
    typed: true
    named: true
    handler: pushMember

  'member':
    type: 'MEM'
    synonyms: 'var'
    modifiers: 'default'
    typed: true
    named: true
    handler: pushMember

  'enum':
    type: 'MEM'
    typed: true
    named: true
    description: true
    summary: true
    handler: pushMember

  'struct':
    type: 'MEM'
    modifiers: 'field'
    named: true
    description: true
    summary: true
    handler: pushMember

  'constant':
    type: 'MEM'
    synonyms: 'const'
    typed: true
    named: true
    handler: pushMember

  'event':
    type: 'EVT'
    named: true
    handler: pushMember

  # -- Member Modifier Tags --

  'param':
    type: 'MMOD'
    synonyms: 'arg argument'
    modifiers: 'default'
    typed: true
    named: true
    handler: pushModifier

  'this':
    type: 'MMOD'
    handler: pushModifier

  'returns':
    type: 'MMOD'
    synonyms: 'return'
    typed: true
    handler: pushModifier

  'throws':
    type: 'MMOD'
    typed: true
    handler: pushModifier

  'getter':
    type: 'MMOD'
    handler: pushModifier

  'setter':
    type: 'MMOD'
    handler: pushModifier

  'readonly':
    type: 'MMOD'
    handler: trueHandler

  'writeonly':
    type: 'MMOD'
    handler: trueHandler

  'default':
    type: 'MMOD'
    handler: contentHandler

  'memberof':
    type: 'MMOD'
    handler: pushModifier

  'override':
    type: 'MMOD'

  'abstract':
    type: 'MMOD'

  'static':
    type: 'MMOD'
    handler: trueHandler

  'instance':
    type: 'MMOD'
    handler: trueHandler

  'fires':
    type: 'MMOD'
    synonyms: 'emits'
    named: true

  # -- Access Modifier Tags --

  'access':
    type: 'AMOD'
    values: 'private public protected'
    handler: (tag, n, t, c, d, s, context) ->
      target.props.access = c

  'private':
    type: 'MMOD'
    handler: (tag, n, t, c, d, s, context) ->
      target.props.access = 'private'

  'protected':
    type: 'MMOD'
    handler: (tag, n, t, c, d, s, context) ->
      target.props.access = 'protected'

  'public':
    type: 'MMOD'
    handler: (tag, n, t, c, d, s, context) ->
      target.props.access = 'public'

  # -- Special Tags --

  'file':
    type: 'SPC'
    synonyms: 'fileoverview overview'

  'author':
    type: 'SPC'
    handler: contentHandler

  'version':
    type: 'SPC'
    handler: contentHandler

  'license':
    type: 'SPC'
    handler: contentHandler

  'requires':
    type: 'SPC'
    handler: pushMember

  'copyright':
    type: 'SPC'
    handler: contentHandler

  'deprecated':
    type: 'SPC'
    handler: trueHandler

  'example':
    type: 'SPC'
    handler: contentHandler

  'tutorial':
    type: 'SPC'
    handler: contentHandler

  'see':
    type: 'SPC'
    handler: contentHandler

  'since':
    type: 'SPC'
    handler: contentHandler

  'extends':
    type: 'SPC'
    handler: contentHandler

  'todo':
    type: 'SPC'
    handler: (tag, n, t, c, d, s, context) ->
      target.todos = [] unless target.todos?
      target.todos.push c

  'ignore':
    type: 'SPC'

  'description':
    type: 'SPC'
    synonyms: 'desc'
    handler: (tag, n, t, c, d, s, context) ->
      target.description = c

  'summary':
    type: 'SPC'
    handler: (tag, n, t, c, d, s, context) ->
      target.summary = c

  'inner':
    type: 'SPC'

  'name':
    type: 'SPC'

  'type':
    type: 'SPC'

  'global':
    type: 'SPC'

  'inheritdoc':
    type: 'SPC'

# Explode all the synonyms
for k, v of TAGS
  if v.synonyms?
    synonyms = v.synonyms.split(' ')
    v.synonyms = null
    for s in synonyms
      TAGS[s] = v

TL_TAGS = []

# Find all the TL tags.
for k, v of TAGS
  if v.type == 'TL'
    TL_TAGS.push(k)

# The comment regex pulls comment blocks from the code.
COMMENT_BLOCK_REGEX = /\s*##\n*([ ]*#.*\n)*/g

# Strip leading comments markers regex.
COMMENT_MARKER_REGEX = /^\s*#+/gm

# Generate the list of tags.
TAGS_LIST = Object.keys TAGS

TAGS_ORD = '(' + TAGS_LIST.join('|') + ')'

# Regular expression to extract tags and their associated content from a
# string.
TAG_REGEX = new RegExp("@#{TAGS_ORD}((?!@#{TAGS_ORD}).)*", 'g')

# Extracts the writeup from the top of the documentation block, before the
# first tag.
WRITEUP_REGEX = new RegExp("((?!@#{TAGS_ORD}).)*")

# Regex to grab the first sentence from a block of text.
SUMMARY_REGEX = /^(.*?)[.?!]/

TYPE_PART = "{\w+}"

NAME_PART = "\w+"

TAG_PARTS_REGEX = new RegExp("@#{TAGS_ORD}\s+#{TYPE_PART}\s+[\w\[\]=]+")

TAG_PARTS_UNTYPED_NONAME = new RegExp("@#{TAGS_ORD}\\s+(.*)")

TAG_PARTS_UNTYPED_NAMED = new RegExp("@#{TAGS_ORD}\\s+(\\w+)(\\s+(.*)|)")

TAG_PARTS_TYPED_NAMED = new RegExp("@#{TAGS_ORD}\\s+\\{(\\w+)\\}\\s+(\\w+)(\\s+(.*)|)")

parser =

  reset: ->
    documentation =
      classes:    {}
      modules:    {}
      namespaces: {}
      files:      {}


  # Reads the source file at the given path.
  read: (path, cb) ->
    scope =
      type: 'files'
      name: path
    resetContext(scope)
    fs.readFile path, {encoding: 'utf8'}, cb


  # Parses the documentation of the file at the passed path.
  parse: (path, cb) ->
    cb = parser.showDoc unless cb
    async.waterfall [
      (q) -> parser.read(path, q)
      parser.extactBlocks
      parser.parseBlocks
      (q) ->
        cb(documentation)
    ]


  # Extracts documentation blocks from the passed source.
  extactBlocks: (source, cb) ->
    r = source.match(COMMENT_BLOCK_REGEX)
    blocks = []
    for t in r
      t = t.replace(COMMENT_MARKER_REGEX, '')
      lines = _str.lines(t)
      cleaned = []
      for line in lines
        line = _str.clean(line)
        line = _str.trim(line)
        if line.length > 0 then cleaned.push line
      cleaned = cleaned.join(' ')
      blocks.push(cleaned)
    cb(null, blocks)


  # Parses an array of documentation blocks from a source file.
  parseBlocks: (blocks, cb) ->
    for block in blocks
      parser.parseBlock block
    cb(null)


  # Parses a single block of documentation.
  parseBlock: (blockContent) ->
    context = target = scope
    s = WRITEUP_REGEX.exec(blockContent)
    description = _str.trim(s[0])
    summary = parser.parseSummary(description)
    while (m = TAG_REGEX.exec(blockContent)) != null
      parser.parseTag(m[0], m[1], description, summary, context)
    parser.writeScope(context)


  # Parses-out the summary and description from a documentation block.
  parseSummary: (str) ->
    s = SUMMARY_REGEX.exec(str)
    if s == null then '' else s[0]


  # Parses and handles each individual tag.
  parseTag: (str, tag, description, summary, context) ->
    t = TAGS[tag]
    if !t.typed and !t.named
      r = TAG_PARTS_UNTYPED_NONAME.exec(str)
      if r != null
        content = r[2]
      else
        content = ''
    else if !t.typed and t.named
      r = TAG_PARTS_UNTYPED_NAMED.exec(str)
      if r != null
        name = r[2]
        content = r[3]
      else
        content = ''
    else if t.typed and t.named
      r = TAG_PARTS_TYPED_NAMED.exec(str)
      if r != null
        type = r[2]
        name = r[3]
        content = r[4]
      else
        content = ''
    else
      content = ''
    content = _str.trim(content)
    if t.handler? then t.handler(tag, name, type, content, description, summary, context)


  writeScope: (context) ->
    if !documentation[scope.type][scope.name]
      documentation[scope.type][scope.name] = _.omit(context, 'name', 'type')


  parseType: (type) ->


  # Writes the documentation object to standard-out.
  showDoc: ->
    console.log JSON.stringify(documentation, undefined, 2)


parser.reset()

module.exports = parser

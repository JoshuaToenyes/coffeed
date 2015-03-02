##
# Defines the Symbol classes and dynamically creates tag-specific symbol
# classes.
#
# @fileoverview

_    = require 'lodash'
tags = require './tags'


symbolClasses = {}

##
# Defines a generic documentatin symbol object.
#
# @class Symbol
# @abstract

class Symbol

  ##
  # Symbol class constructor.
  #
  # @constructor

  constructor: ->
    @file = null
    @namepath = null

  ##
  # Returns true if this symbol can have modifiers attached.
  #
  # @returns {boolean} True if this symbol is modifiable.
  #
  # @method isModifiable
  # @public

  isModifiable: -> @ instanceof Modifiable


  ##
  # Returns true if this is a block-level symbol.
  #
  # @returns {boolean} True if this is a block-level symbol.
  #
  # @method isBlock
  # @public

  isBlock: -> @ instanceof Block


  ##
  # Returns true if this is a member-level symbol.
  #
  # @returns {boolean} True if this is a member symbol.
  #
  # @method isMember
  # @public

  isMember: -> @ instanceof Member


  ##
  # Returns true if this is a modifier symbol.
  #
  # @returns {boolean} True if this is a modifier symbol.
  #
  # @method isModifier
  # @public

  isModifier: -> @ instanceof Modifier

  ##
  # Returns true if this is an access symbol.
  #
  # @returns {boolean} True if this is an access symbol.
  #
  # @method isAccess
  # @public

  isAccess: -> @ instanceof Access


  ##
  # Returns true if this is an auxiliary symbol.
  #
  # @returns {boolean} True if this is an auxiliary symbol.
  #
  # @method isAuxiliary
  # @public

  isAuxiliary: -> @ instanceof Auxiliary


##
# Defines a symbol which may be modified by modifier tags.
#
# @class Modifiable
# @extends Symbol
# @class abstract

class Modifiable extends Symbol

  ##
  # Modifiable class constructor.
  #
  # @constructor

  constructor: ->
    super()
    @members = []

  addMember: (member) ->
    @members.push member


##
# Represents a block-level symbol such as a namespace, class, module, etc.
#
# @class Block
# @extends Modifiable
# @abstract

symbolClasses['block'] = class Block extends Modifiable

  ##
  # Block class constructor.
  #
  # @constructor

  constructor: ->
    super()


##
# Represents a member-level symbol such as a method, function, property, etc.
#
# @class Member
# @extends Modifiable
# @abstract

symbolClasses['member'] = class Member extends Modifiable

  ##
  # Member class constructor.
  #
  # @constructor

  constructor: ->
    super()


##
# Represents a modifier documentation symbol, such as a method's parameter,
# an "abstract" label, etc.
#
# @class Modifier
# @extends Symbol
# @abstract

symbolClasses['modifier'] = class Modifier extends Symbol

  ##
  # Modifier class constructor.
  #
  # @constructor

  constructor: ->
    super()


##
# Represents an access-symbol, such as public, private, protected, etc.
#
# @class Access
# @extends Symbol
# @abstract

symbolClasses['access'] = class Access extends Symbol

  ##
  # Access class constructor.
  #
  # @constructor

  constructor: ->
    super()


##
# Represents an auxiliary documentation symbol, such as a code example, author,
# copyright notice, license, etc.
#
# @class Auxiliary
# @extends Symbol
# @abstract

symbolClasses['auxiliary'] = class Auxiliary extends Symbol

  ##
  # Auxiliary class constructor.
  #
  # @constructor

  constructor: ->
    super()


##
# Custom symbol classes... TBD.
# @todo What can we do here...?

customClasses = {}


##
# Private function which creates a new unique class for the passed symbol name
# and parent. The newly created class will then be attached to the
# module exports for use throughout the parser.
#
# @param {string} Name - The name of the symbol class to create.
#
# @param {Symbol} parent - The parent symbol class to extend.
#
# @function createSymbolClass
# @private

createSymbolClass = (Name, parent) ->
  name = Name
  if _.has(customClasses, Name)
    module.exports[Name] = customClasses[Name]
  else
    module.exports[Name] = class extends parent
      constructor: () ->
        @type = name
        super()

for tagName, tag of tags
  createSymbolClass tagName, symbolClasses[tag::definition.type]

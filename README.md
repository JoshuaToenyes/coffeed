# coffeed

Coffeed makes no assumptions about the code, and in-fact doesn't even read it.

## Core Concepts

All documented symbols belong to one of the following:

- @namespace
- @module
- @class
- @mixin

If none of the above are present, then the file is treated as the top-level
element and the document symbols are attached to that.

### Modifiers

In general, any tag can have modifiers associated with it. Modifiers are other
tags which add data to the tag being modified, and must appear within the same
documentation block as the tag being modified. An example is the @struct tag,
which can be modified with the @field tag.

    @struct myStruct
    @field {number}        num=0       Number of widgets.
    @field {string}        fav=''      Name of favorite widget.
    @field {Array<Widget>} widgets=[]  Array of widgets.

The above documentation block defines a struct named `myStruct` with three
fields. The @field are the modifier tags, acting on the modified tag @struct.




## Block Tags
Block tags define possibly large bodies of code with follow on methods,
properties, members, etc. documented in the follow-on lines of code. Thus,
once a block-tag is encountered it is assumed that follow-on documentation
symbols are members of the previous block.

### @class <name>
Used to define a CoffeeScript class, a symbol that is intended to be
called with the `new` keyword.

#### @abstract
This class should not be instantiated directly, but instead on of it's
ancestors. should be used.

#### @extends <parent>
Documents that this class extends from the parent class.

### @namespace <name>
Document a namespace object such as `window` or `global`. A namespace is
essentially just an Object.

### @module <name>
Document a CommonJS or AMD module.




## Block Modifier Tags

### @mixes <mixin>
This object mixes in all the members from another object.




## Member Tags
Classes, modules, namespaces or files can all have members attached to them.
These member may be any of the following tags.

### @function <name> (synonyms: @func, @method, @constructor)
Describe a function or method.

#### @param {type} <name> or \[name\] or \[name=default\] (synonyms: @arg, @argument)
Document the parameter to a function.

##### @default <value> (synonyms: @defaultvalue)
Document the default value of a parameter.

#### @this
What does the 'this' keyword refer to here?

#### @returns {type} (synonyms: @return)
Document the return value of a function or method.

#### @throws {type} (synonyms: @exception)
Describe what errors could be thrown.

### @constructor
Same features as @function, but documents the special method within a
CoffeeScript that acts as the class's constructor. See @function.

### @property {type} <name> (synonyms: @prop)
Document a property of an object.

#### @setter
Documents a setter function (see @function) for this property.

#### @getter
Documents a getter function (see @function) for this property.

#### @readonly
This symbol is meant to be read-only.

### @typedef {type} <name>
Document a custom type.

### @member {type} <name> (synonyms: @var)
Document a member.

#### @default (synonyms: @defaultvalue)
Document the default value of a member.

### @enum {type} <name>
Document a collection of related properties.

### @struct <name>
Defines a struct, a standardized object representation.

#### @field {type} <name>
Defines a field on a struct. Fields will always be added to the most recently
documented struct.

### @constant {type} <name> (synonyms: @const)
Document an object as a constant.




## Member Modifier Tags
Members can be modified in a variety of ways.

### @memberof
This tag can be used to override the assumed parent-child relationship between
a member and it's parent.

Also, classes, namespaces, and modules can use @memberof to establish
hierarchical relatinoships. i.e.

@class MyClass
@memberof myModule/subModule

would establish the class at the namepath myModule/subModule.MyClass

Note too, that the last module in a namepath is essentially identical to a
namespace.

### @override
Indicate that a symbol overrides its parent.

### @abstract
This member must be defined by an inheriting class.

### @static
This member is static, so it belongs to the prototype of a class.

### @instance
Documents an instance member, `MyClass#instanceMember'. By default, members
are instance members on classes and static on namespaces and modules (since
namespaces and modules should not be instantiated). To uglify documentation
however, this can be overridden.




## Access Modifier Tags
Both members and classes may have access modified tags.

### @access
Specify the access level of this member (private, public, or protected).

### @private
This symbol is meant to be private.

### @protected
This symbol is meant to be protected.

### @public
This symbol is meant to be public.




## Event Tags

Members, classes, modules or namespaces may define, fire, or emit events.

Events should be namespaces with colons, i.e.

myModule/submodule.MyClass:myEvent:subEvent
myNamespace.subNamespace.MyClass:eventName

etc...

### @event <name>
Documents an event.

### @fires <name> (synonyms: @emits)
Describe the events this method may fire.





## Special Tags

### @file (synonyms: @fileoverview, @overview)
Describe a file.

#### @requires
This file requires the documented module.

#### @author
Defines the author of the file.

#### @version
Defines the version of the file.

#### @copyright
Document some copyright information about the file.

#### @license
Identify the license that applies to the code in this file.

### @deprecated
Document that a member, class, symbol, or other item is deprecated and is
no longer preferred.

### @example
Provide an example of how to use a documented item.

### @tutorial
Insert a link to an included tutorial file.

### @see
Refer to some other documentation for more information.

### @since
When was this feature added?

### @todo
Document tasks to be completed.

### @ignore
Ignores the entire document block.

### @description (synonyms: @desc)
By default, the first sentence of a documentation block is the summary, and
the the entire text is the description. This may be overridden with the
@description and @summary tags.

### @summary
A shorter version of the full description. See @description.

### @inner
Document an inner object. This essentially prevents breaking out of the current
documentation block and starting a new one.

### @name
Document the name of an object.

### @type
Document the type of an object.

### @global
Document a global object.

### @inheritdoc
Indicate that a symbol should inherit its parent's documentation.

module.exports =

  unknownDoclet: (segment) ->
    console.log 'WARNING: Cannot classifiy doclet: ', segment.doclet

  implicitFileOverview: (segment) ->
    console.log 'WARNING: Assuming @fileoverview: ', segment.doclet

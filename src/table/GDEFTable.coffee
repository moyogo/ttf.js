# # ttf.js - JavaScript TrueType Font library
#
# Copyright (C) 2014 by ynakajima (https://github.com/ynakajima)
# Copyright (C) 2014 by Daton Maag Ltd.
#
# Released under the MIT license.

Common = require ('./Common') 

# ## GDEF table Class
class GDEFTable
  constructor: () ->
    version = 0
  
  # Create GDEFTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @param {TrueType} ttf 
  # @return {GDEFTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    GDEF = {}
    
    GDEF.version = version = view.getUlong()

    if version isnt 0x00010000 and version isnt 0x00010002
      console.log 'invalid version'
    glyphClassDefOffset = view.getUshort()
    attachListOffset = view.getUshort()
    ligCaretListOffset = view.getUshort()
    markAttachClassDefListOffset = view.getUshort()
    if version is 0x00010002
      markGlyphSetsDefOffset = view.getUshort()
    
    glyphClassDef = new ClassDefinitionTable()
    GDEF.glyphClassDef = glyphClassDef.createFromTTFDataView(view, offset + glyphClassDefOffset)
    
    GDEF
  
  # Create GDEFTable from JSON
  # @param {Object|String} json
  # @return {GDEFTable}
  @createfromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    GDEF = new GDEFTable()
    GDEF.version = json.version
    GDEF.glyphClassDef = ClassDefinitionTable.createFromJSON(json.glyphClassDef)
        
    GDEF
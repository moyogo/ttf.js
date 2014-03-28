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
  # @return {GDEFTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    GDEF = {}
    
    GDEF.version = version = view.getUlong()

    if version isnt 0x00010000 and version isnt 0x00010002
      console.log 'invalid version GDEF'
    glyphClassDefOffset = view.getUshort()
    attachListOffset = view.getUshort()
    ligCaretListOffset = view.getUshort()
    markAttachClassDefListOffset = view.getUshort()
    if version is 0x00010002
      markGlyphSetsDefOffset = view.getUshort()
    
    if glyphClassDefOffset
      glyphClassDef = new ClassDefinitionTable()
      GDEF.glyphClassDef = glyphClassDef.createFromTTFDataView(view, offset + glyphClassDefOffset)
    
    if attachListOffset
      GDEF.attachList = new ClassDefinitionTable()
    
    if ligCaretListOffset
      GDEF.ligCaretList = LigCaretListTable.createFromTTFDataView(view, offset + ligCaretListOffset)
    
    # if markAttachClassDefListOffset
#       GDEF.markAttachClassDefList = new MarkAttachClassDef()
#     
#     if markGlyphSetsDefOffset
#       GDEF.markGlyphSetsDef = new markGlyphSetsDef() 
    
    GDEF
  
  # Create GDEFTable from JSON
  # @param {Object|String} json
  # @return {GDEFTable}
  @createfromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    GDEF = new GDEFTable()
    GDEF.version = json.version
    if json.glyphClassDef isnt undefined
      GDEF.glyphClassDef = ClassDefinitionTable.createFromJSON(json.glyphClassDef)
    if json.attachList isnt undefined
      GDEF.attachList = AttachmentListTable.createFromJSON(json.attachList)
        
    GDEF

# TODO
# ## Attachment List table Class
class AttachmentListTable
  constructor: () ->
    @glyphCount = 0
  
  # Create AttachmentListTable instance from TTFDataView
  # @param (TTFDataView) view
  # @param (Number) offset
  # @return {AttachmentListTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    attachmentListTable = new AttachmentListTable()
    
    coverageOffset = view.getUshort()
    coverage = CoverageTable.createFromTTFDataView(view, offset + coverageOffset)
    attachmentListTable.glyphCount = glyphCount = view.getUshort()
    attachPointOffset = view.getUshort()
    
    attachmentListTable
  
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    attachmentListTable = new AttachmentListTable()
    attachmentListTable.glyphCount = json.glyphCount

class LigCaretListTable
  constructor: () ->
    @ligGlyphCount = 0
  
  # Create LigCaretListTable instance from TTFDataView
  # @param (TTFDataView) view
  # @param (Number) offset
  # @return {LigCaretListTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    ligCaretList = new LigCaretListTable()
    coverageOffset = view.getUshort()
    coverage = CoverageTable.createFromTTFDataView(view, offset + coverageOffset)
    ligCaretList.coveage = coverage
    ligCaretList.ligGlyphCount = ligGlyphCount = view.getUshort()
    
    ligCaretList
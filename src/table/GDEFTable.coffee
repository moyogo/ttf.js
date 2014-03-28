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
      GDEF.glyphClassDef = ClassDefinitionTable.createFromTTFDataView(view, offset + glyphClassDefOffset)
    
    if attachListOffset
      GDEF.attachList = AttachmentListTable.createFromTTFDataView(view, offset + attachListOffset)
    
    if ligCaretListOffset
      GDEF.ligCaretList = LigCaretListTable.createFromTTFDataView(view, offset + ligCaretListOffset)
    
    if markAttachClassDefListOffset
      GDEF.markAttachClassDefList = ClassDefinitionTable.createFromTTFDataView(view, offset + markAttachClassDefListOffset)
    
    if markGlyphSetsDefOffset
      GDEF.markGlyphSetsDef = MarkGlyphSetsDef.createFromTTFDataView(view, offset + markGlyphSetsDefOffset)
    
    # return
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
    if json.ligCaretList isnt undefined
      GDEF.ligCaretList = LigCaretListTable.createFromJSON(json.ligCaretList)
    if json.markAttachClassDefList isnt undefined
      GDEF.markAttachClassDefList = ClassDefinition.createFromJSON(json.markAttachClassDefList)
    if json.markGlyphSetsDef isnt undefined
      GDEF.markGlyphSetsDef = MarkGlyphSetsDef.createFromJSON(json.markGlyphSetsDef)

    # return
    GDEF

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
    attachmentListTable.coverage = CoverageTable.createFromTTFDataView(view, offset + coverageOffset)
    
    view.seek (offset + 2)
    attachmentListTable.glyphCount = glyphCount = view.getUshort()
    attachPointOffset = view.getUshort()
    
    # return
    attachmentListTable
  
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    attachmentListTable = new AttachmentListTable()
    attachmentListTable.glyphCount = json.glyphCount
    attachmentListTable.coverage = CoverageTable.createFromJSON(json.coverage)
    
    # return
    attachmentListTable

# ## LigCaret List table Class
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
    
    view.seek (offset + 2)
    ligCaretList.coverage = coverage
    ligCaretList.ligGlyphCount = ligGlyphCount = view.getUshort()
    
    ligGlyph = []
    if ligGlyphCount > 0
      for i in [0..ligGlyphCount]
        caretCount = view.getUshort()
        caretValueOffset = view.getUshort()
        caretValue = CaretValueTable.createFromTTFDataView(view, offset + caretValueOffset)
        ligGlyph.push {
          'caretCount': caretCount
        }
    
    # return
    ligCaretList

  # Create LigCaretListTable from JSON
  # @param {Object|String} json
  # @return {LigCaretListTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON parse json
    
    ligCaretList = new LigCareListTable()
    ligCareList.coverage = CoverageTable.createFromJSON(json.coverage)
    
    # return
    ligCaretList

# ## CaretValue table Class
class CaretValueTable
  constructor: () ->
    @format = 0
  
  # Create CaretValueTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {CaretValueTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    caretValueTable = new CaretValueTable()
    
    caretValueTable.format = format = view.getUshort()
    
    switch format
      when 1
        caretValueTable.coordinate = view.getShort()
      when 2
        caretValueTable.caretValuePoint =  view.getUshort()
      when 3
        caretValueTable.coordinate = view.getShort()
        deviceTableOffset = view.getShort()
        caretValueTable.deviceTable = DeviceTable.createFromTTFDataView(view, offset + deviceTableOffset)
    
    # return
    caretValueTable
  
  # Create CaretValueTable from JSON
  # @param {Object|String} json
  # @return {CaretValueTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    caretValueTable = new CaretValueTabel()
    caretValueTable.format = format = json.format
    
    switch format
      when 1
        caretValueTable.coordinate = json.coordinate
      when 2
        caretvalueTable.caretValuePoint = json.caretValuePoint
      when 3  
       caretValueTable.coordinate = json.coordinate
       caretValueTable.deviceTable = DeviceTable.createFromJSON(json.devicetable)
    
    # return
    caretValueTable

# ## MarkGlyphSetsDef Class
class MarkGlyphSetsDef
  constructor: () ->
    @format = 0
  
  # Create MarkGlyphSetsDef instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {MarkGlyphSetsDef}
  @createFromTTFView: (view, offset) ->
    markGlyphSetsDef = new MarkGlyphSetsDef()
    
    markGlyphSetsDef.format = format = view.getUshort()
    markGlyphSetsDef.markSetCount = markSetCount = view.getUshort()
    
    coverages = []
    if markSetCount > 0
      for i in [0..markSetCount-1]
        coverageOffset = view.getUlong()
        coverage = CoverageTable.createFromTTFDataView(view, offset + coverageOffset)
        coverages.push coverage
        view.seek (offset + 4 + i*4)
    
    markGlyphSetsDef.coverages = coverages
    
    # return
    markGlyphSetsDef
    
  # Create MarkGlyphSetsDef from JSON
  # @param {Object|String} json
  # @return {MarkGlyphSetsDef}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    markGlyphSetsDef = new MarkGlyphSetsDef()
    markGlyphSetsDef.format = json.format
    markGlyphSetsDef.markSetCount = markSetCount = json.markSetCount
    
    coverages = []
    if markSetCount > 0
      for i in [0..markSetCount-1]
        coverage = CoverageTable.createFromJSON(json.coverages[i])
        coverages.push coverage
    markGlyphSetsDef.coverages = coverages
    
    # return
    markGlyphSetsDef
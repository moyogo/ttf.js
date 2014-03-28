# # ttf.js - JavaScript TrueType Font library
#
# Copyright (C) 2014 by ynakajima (https://github.com/ynakajima)
# Copyright (C) 2014 by Daton Maag Ltd.
#
# Released under the MIT license.

# ## Common Table Formats

# ## Coverage Table
class CoverageTable
  constructor: () ->
    @coverageFormat = 0
  
  # Create CoverageTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {CoverageTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    coverageTable = new CoverageTable()
    
    coverageTable.coverageFormat = coverageFormat = view.getUshort()
    
    if coverageFormat is 1
      coverageTable.glyphCount = glyphCount = view.getUshort()
      glyphArray = []
      
      if glyphCount > 0
        for i in [0..glyphCount-1]
          glyphId = view.getUshort()
          glyphArray.push glyphId
      coverageTable.glyphArray = glyphArray
    
    if coverageFormat is 2
      rangeCount = view.getUshort()
      rangeRecord = []
      if rangeCount > 0
        for i in [0..rangeCount-1]
          start = view.getUshort()
          end = view.getUshort()
          startCoverageIndex = view.getUshort()
          rangeRecord.push {
            start: start,
            end: end,
            startCoverageIndex : startCoverageIndex
          }
      coverageTable.rangeRecord = rangeRecord

    # return
    coverageTable
  
  # Create CoverageTable from JSON
  # @param {Object|String} json
  # @return {CoverageTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    coverageTable = new CoverageTable()
    coverageTable.coverageFormat = coverageFormat = json.coverageFormat
    if coverageFormat is 1
      coverageTable.glyphArray = json.glyphArray
    if coverageFormat is 2
      coverageTable.rangeRecord = json.rangeRecord
    
    # return
    coverageTable 
  
# ## Class Definition Table
class ClassDefinitionTable
  constructor: () ->
    @classFormat = 0
  
  # Create ClassDefinitionTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {ClassDefinitionTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    classDefTable = new ClassDefinitionTable()
    classDefTable.classFormat = classFormat = view.getUshort()
    
    classValueArray = []
    if classFormat is 1
      startGlyph = view.getUshort()
      glyphCount = view.getUshort()
      classValueArray = []
      
      if glyphCount > 0
        for i in [0..glyphCount-1]
          classId = view.getUshort()
          classValueArray.push {
            gId: startGlyph + i,
            class: classId
          }
    
    if classFormat is 2
      classRangeCount = view.getUshort()
      classRangeRecords = []
      
      if classRangeCount > 0
        for i in [0..classRangeCount-1]
          start = view.getUshort()
          end = view.getUshort()
          classId = view.getUshort()
          for j in [start..end]
            classValueArray.push {
              gId: j,
              class: classId
            }
    classDefTable.classValueArray = classValueArray
    
    # return
    classDefTable
  
  # Create ClassDefTable from JSON
  # @param {Object|String} json
  # @return {ClassDefTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    classDefTable = new ClassDefTable()
    classDefTable.classFormat = json.classFormat
    classDefTable.classValueArray = json.classValueArray
    
    # return
    classDefTable
    
# ## Device Table
class DeviceTable
  constructor: () ->
    @startSize = null
    @endSize = null
    @deltaFormt = 0
    @deltaValue = []

  # Create DeviceTable from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {DeviceTable}
  @createFromTTFDataView: (view, offset) ->
    deviceTable = new DeviceTable()
    deviceTable.startSize = view.getUshort()
    deviceTable.endSize = view.getUshort()
    deviceTable.deltaFormat = view.getUshort()
    # TODO
    #deviceTable.deltaValue
    
    # return
    deviceTable
  
  # Create DeviceTable from JSON
  # @param {Object|String} json
  # @return {DeviceTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    deviceTable = new DeviceTable()
    devicaTable.startSize = json.startSize
    devicaTable.endSize = json.endSize
    deviceTable.deltaFormat = json.deltaFormat
    # TODO
    #deviceTable.deltaValue

# exports
module.exports = ClassDefinitionTable
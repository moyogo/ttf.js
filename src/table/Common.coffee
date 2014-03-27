# # ttf.js - JavaScript TrueType Font library
#
# Copyright (C) 2014 by ynakajima (https://github.com/ynakajima)
# Copyright (C) 2014 by Daton Maag Ltd.
#
# Released under the MIT license.

# ## Common Table Formats

# ## Class Definition Table
class ClassDefinitionTable
  constructor: () ->
    @classFormat = 0
  
  # Create ClassDefinitionTable instance from TTFDataView
  # @parama {TTFDataView} view
  # @param {Number} offset
  # @param {TrueType} ttf
  # @return {GDEFTable}
  createFromTTFDataView: (view, offset) ->
    view.seek offset
    classDefTable = new ClassDefinitionTable()
    classDefTable.classFormat = classFormat = view.getUshort()
    
    classValueArray = []
    if classFormat is 1
      startGlyph = view.getUshort()
      glyphCount = view.getUshort()
      classValueArray = []
      for i in [0..glyphCount-1]
        classId = view.getUshort()
        classValueArray.push {
          gId: startGlyph + i,
          class: classId
        }
    
    if classFormat is 2
      classRangeCount = view.getUshort()
      classRangeRecords = []
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
    
    classDefTable

# exports
module.exports = ClassDefinitionTable
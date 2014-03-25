# # ttf.js - JavaScript TrueType Font library
#
# Copyright (C) 2014 by ynakajima (https://github.com/ynakajima)
#
# Released under the MIT license.

# ## Cmap table Class
class CmapTable
  constructor: () ->
    @tableVersion = 0
    @tables = []

  # Create CmapTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @param {TrueType} ttf
  # @return {CmapTable}
  @createFromTTFDataView: (view, offset, ttf) ->
    view.seek offset
    cmap = new CmapTable()
    
    cmap.tableVersion = view.getUshort()
    numSubTables = view.getUshort()
    indeces = []
    
    for i in [0..numSubTables - 1]
      view.seek offset + (i*8) + 4
      platformId = view.getUshort()
      encodingId = view.getUshort()
      subTableOffset = view.getUlong()
      index = -1
      
      if (indeces.indexOf subTableOffset) is -1
        index = Object.keys(indeces).length
        indeces.push subTableOffset
        
        subTable = CmapSubTable.createFromTTFDataView(view, offset + subTableOffset, ttf)
        subTable.platformId = [platformId]
        subTable.encodingId = [encodingId]
        
        cmap.tables.push subTable
      else
        index = indeces.indexOf subTableOffset
        cmap.tables[index].platformId.push platformId
        cmap.tables[index].encodingId.push encodingId
    
    # return cmap
    cmap
  
  # Create CmapTable from JSON
  # @param {Object|String} json
  # @return {CmapTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    cmap = new CmapTable()
    
    cmap.tableVersion = json.tableVersion
    
    for table in json.tables
      cmap.tables.push(CmapSubTable.createFromJSON(table))
    
    # return cmap
    cmap


class CmapSubTable
  constructor: () ->
    @platformId = null
    @encodingId = null
  
  # Create CmapSubTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @param {TrueType} ttf
  # @return {CmapSubTable}
  @createFromTTFDataView: (view, offset, ttf) ->
    view.seek offset
    subTable = new CmapSubTable()
    subTable.format = view.getUshort()
    mapping = []
    
    # format 0
    if subTable.format is 0
      length = view.getUshort()
      subTable.language = view.getUshort()
      for i in [0..255]
        glyphId = view.getByte()
        map = {
          code: '0x' + i.toString(16)
          gId: glyphId
        }
        mapping.push map
    
    # format 2
    if subTable.format is 2
      length = view.getUshort()
      subTable.language = view.getUshort()
      
      subHeaderKeys = {}
      maxSubHeaderIndex = 0
      for subHeaderKey in [0..255]
        subHeaderIndex = view.getUshort() / 8  # value is subHeader index * 8
        if subHeaderIndex > 0
          subHeaderKeys[subHeaderIndex] = subHeaderKey
          if maxSubHeaderIndex < subHeaderIndex
            maxSubHeaderIndex = subHeaderIndex
      
      subHeaders = []
      glyphIndexArray = []
      for subHeaderIndex in [0..maxSubHeaderIndex]
        firstCode = view.getUshort()
        entryCount = view.getUshort()
        idDelta = view.getShort()
        idRangeOffset = view.getUshort()
        
        currentOffset = offset + 6 + 256*2 + (subHeaderIndex+1)*8
        rangeOffset = currentOffset + idRangeOffset
        
        # skip to glyphIdArray
        view.seek rangeOffset
        
        if subHeaderIndex > 0
          hiBytes = subHeaderKeys[subHeaderIndex]
        
        for id in [0..entryCount-1]
          glyphId = view.getUshort()

          if glyphId > 0
            glyphId = (glyphId + idDelta) % 0x10000
            charCode = id + firstCode
            
            if subHeaderIndex > 0
              charCode = hiBytes*256 + charCode
            
            map = {
              code : '0x' + charCode.toString(16)
              gId : glyphId
            }
            mapping.push map
        
        # skip back to where we read idRangeOffset
        view.seek currentOffset
    
    # format 4
    if subTable.format is 4
      length = view.getUshort()
      subTable.language = view.getUshort()
      segCount = view.getUshort() >> 1 # 2xsegCount
      searchRange = view.getUshort()
      entrySelector = view.getUshort()
      rangeShift = view.getUshort()
      endCount = []
      for i in [0..segCount-1]
        endCount.push view.getUshort()
      reservePad = view.getUshort()
      startCount = []
      for i in [0..segCount-1]
        startCount.push view.getUshort()
      idDelta = []
      for i in [0..segCount-1]
        idDelta.push view.getShort()
      idRangeOffset = []
      for i in [0..segCount-1]
        idRangeOffset.push view.getUshort()
      
      mapping= []
      
      for i in [0..segCount-1]
        #console.log '' + subTable.startCount[i] + ' -- ' + subTable.endCount[i]
        for j in [0..(endCount[i] - startCount[i])]
          charCode = j + startCount[i]
          #glyphCode = view.getUshort()
          glyphId = charCode + idDelta[i]
          #console.log '' + codeValue + ' ' + glyphCode + ' ' + glyphId
          codePoint = '0x' + charCode.toString(16)
          mapping.push {
            code: codePoint,
            gId: glyphId
          }

    # format 6
    if subTable.format is 6
      length = view.getUshort()
      subTable.language = view.getUshort()
      firstCode = view.getUshort()
      entryCount = view.getUshort()
      console.log 'firstCode: 0x' + firstCode.toString(16) + ', entryCount: ' + entryCount
      
      for i in [0..entryCount-1]
        glyphId = view.getUshort()
        mapping.push {
          code: i + firstCode
          gId: glyphId
        }
    
    # format 8
    if subTable.format is 8
      reserved = view.getUshort()
      length = view.getUlong()
      subTable.language = view.getUlong()
      is32 = []
      for i in [0..8191]
        is32.push view.getByte()
      nGroups = view.getUlong()
      
      for i in [0..nGroups]
        startCharCode = view.getUlong()
        endCharCode = view.getUlong()
        startGlyphId = view.getUlong()
        
        for j in [startCharCode..endCharCode]
          mapping.push {
            code: j,
            gId: startGlyphId + j
          }
    
    # format 10
    if subTable.format is 10
      reserved = view.getUshort()
      length = view.getUlong()
      subTable.language = view.getUlong()
      startCharCode = view.getUlong()
      numChars = view.getUlong()
      
      for i in [0..numChars]
        mapping.push {
          code: startCharCode + i
          gId: i
        }
    
    # format 12
    if subTable.format is 12
      reserved = view.getUshort()
      length = view.getUlong()
      subTable.language = view.getUlong()
      nGroups = view.getUlong()
      
      for i in [0..nGroups-1]
        startCharCode = view.getUlong()
        endCharCode = view.getUlong()
        startGlyphId = view.getUlong()
        
        for j in [0..(endCharCode - startCharCode)]
          charCode = startCharCode + j
          codePoint = '0x' + charCode.toString(16)
          glyphId = startGlyphId + j
          
          mapping.push {
            code: codePoint,
            gId: glyphId
          }
    
    # format 13
    if subTable.format is 13
      reserved = view.getUshort()
      length = view.getUlong()
      subTable.language = view.getLong()
      nGroups = view.getLong()
      
      for i in [0..nGroups-1]
        startCharCode = view.getUlong()
        endCharCode = view.getUlong()
        glyphId = view.getUlong()
        
        for charCode in [startCharCode..endCharCode]
          mapping.push {
            code: charCode
            gId: glyphId
          }
    
    # format 14
    # TODO, seems to be broken
    if subTable.format is 14
      length = view.getUlong()
      numVarSelectorRecords = view.getUlong()
      varSelectorRecords = []
      
      for i in [0..numVarSelectorRecords-1]
        currentOffset = offset + 2+4+4
        varSelector = '0x' + view.getUint24().toString(16)
        defaultUVSOffset = view.getUlong()
        nonDefaultUVSOffset = view.getUlong()
        
        view.seek offset + defaultUVSOffset
        numUnicodeValueRanges = view.getUlong()
        unicodeValueRanges = []
        
        for j in [0..numUnicodeValueRanges]
          startUnicodeValue = view.getUint24()
          additionalCount = view.getByte()
          for k in [0..additionalCount]
            charCode = startUnicodeValue + k
            unicodeValueRanges.push {
              varSelector: varSelector,
              code: '0x' + charCode.toString(16)
            }
        
        view.seek offset + nonDefaultUVSOffset
        numUVSMappings = view.getUlong()
        
        for j in [0..numUVSMappings-1]
          unicodeValue = view.getUint24()
          glyphId = view.getUshort()
          unicodeValueRanges.push {
            varSelector: varSelector,
            code: '0x' + unicodeValue.toString(16),
            gId: glyphId
          }
        
        view.seek currentOffset
        
        varSelectorRecords.push unicodeValueRanges

      mapping = varSelectorRecords
    
    subTable.mapping = mapping
    
    subTable

  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    subTable = new CmapSubTable()
    subTable.platformId = json.platformId
    subTable.encodingId = json.encodingId
    subTable.format = json.format
    subTable.language = json.language
    subTable.mapping = json.mapping
    
    subTable
  
  @isUnicode: () ->
    (@plaformId is 0 or (@plaformId is 3 and (@encodingId is 1 or @encodingId is 1)))
  
  @isSymbol: () ->
    (@platformId is 3 and @encodingId is 0)

# exports
module.exports = CmapTable

# # ttf.js - JavaScript TrueType Font library
#
# Copyright (C) 2014 by ynakajima (https://github.com/ynakajima)
# Copyright (C) 2014 by Daton Maag Ltd.
#
# Released under the MIT license.

# ## Name table Class
class NameTable
  constructor: () ->
    @format = 0
    @count = 0
  
  # Create NameTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @param {TrueType} ttf
  # @return {NameTable}
  @createFromTTFDataView: (view, offset, ttf) ->
    view.seek offset
    name = new NameTable()
    
    name.format = view.getUshort()
    
    name.count = view.getUshort()
    stringOffset = view.getUshort()
    
    nameRecords = Array name.count
    for i in [0..name.count-1]
      currentOffset = offset + 6 + i*12
      view.seek currentOffset

      nameRecord = {}
      nameRecord.platformId = view.getUshort()
      nameRecord.encodingId = view.getUshort()
      nameRecord.languageId = view.getUshort()
      #if nameRecord.languageId >= 0x8000
      #  console.log 'Error: nameRecord.languageId must be less that 0x8000'
      nameRecord.nameId = view.getUshort()
      length = view.getUshort()
      recOffset = view.getUshort()
      
      # UTF-16BE in platformId=3, encodingId=1
      if nameRecord.platformId is 3 and nameRecord.encodingId in [0, 1, 10]
        string = ""
        for j in [0..(length / 2)-1]
          charCode = view.getUshort(offset + stringOffset + recOffset + j*2)
          string += String.fromCharCode(charCode)
      else
        string = view.getString(length, offset + stringOffset + recOffset)
      
      nameRecord.string = string
      
      nameRecords[i] = nameRecord
    
    name.nameRecords = nameRecords
    
    if name.format is 1
        langTagCount = view.getUshort()
        langTagRecords = []
        for i in [0..langTagCount]
           length = view.getUshort()
           recOffset = view.getUshort()
    
    name
  
  # Create NameTable from JSON
  # @param {Object|String} json
  # @return {NameTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    name = new NameTable()
    name.format = json.format
    name.nameRecords = json.nameRecords
        
    name
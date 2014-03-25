# # ttf.js - JavaScript TrueType Font library
#
# Copyright (C) 2013 by ynakajima (https://github.com/ynakajima)
#
# Released under the MIT license.

# require
TTFDataView = require ('./util/TTFDataView')
HeadTable = require ('./table/HeadTable')
MaxpTable = require ('./table/MaxpTable')
LocaTable = require ('./table/LocaTable')
GlyfTable = require ('./table/GlyfTable')
HheaTable = require ('./table/HheaTable')
HmtxTable = require ('./table/HmtxTable')
OS_2Table = require ('./table/OS_2Table')
CmapTable = require ('./table/CmapTable')
PostTable = require ('./table/PostTable')

Glyph = require ('./glyph/Glyph')


# ## TrueType Class
class TrueType
  constructor: () ->
    # sfntHeader 
    @sfntHeader = {
      sfntVersion:   0
      numTables:     0
      searchRange:   0
      entrySelector: 0
      rangeShift:    0
    }

    # offset table
    @offsetTable = []

    # tables
    @head = new HeadTable()
    @maxp = new MaxpTable()
    @loca = new LocaTable()
    @glyf = new GlyfTable()
    @hhea = new HheaTable()
    @hmtx = new HmtxTable()
    @OS_2 = new OS_2Table()
    @cmap = new CmapTable()
    @post = new PostTable()

  # https://developer.apple.com/fonts/TTRefMan/RM06/Chap6.html#ScalerTypeNote
  isMacTTF: () ->
    @sfntHeader.sfntVersion is 'true'

  isWinTTF: () ->
    @sfntHeader.sfntVersion is 1.0

  isTTCF: () ->
    @sfntHeader.sfntVersion is 'ttcf'

  isTTF: () ->
    @isMacTTF() or @isWinTTF() or @isTTCF()

  isOTTO: () ->
    @sfntHeader.sfntVersion is 'OTTO'

  isCFF: () ->
    @isOTTO()

  getNumGlyphs: () ->
    @maxp.numGlyphs

  isLocaLong: () ->
    @head.isLocaLong()

  # Return Glyph at the specified id.
  # @param {Number} id id of Glyph 
  # @return {SimpleGlyph|CompositeGlyph}
  getGlyphById: (id) ->
    if @getNumGlyphs() is 0
      return false

    glyphData = @glyf.getGlyphById id
    if glyphData is false
      return false

    new Glyph glyphData, @

  # Create TrueType instance from TTFDataView
  # @param {Buffer|Array|String} buffer buffer can be either a binary String,
  #                                     any Array-like byte storage
  #                                     (Array, Uint8Array, Arguments, jQuery(Array), ...)
  # @return {TrueType}
  @createFromBuffer: (buffer) ->
    ttf = new TrueType()

    # create TTFDataView
    view = new TTFDataView buffer
    
    # sfntHeader.sfntVersion
    sfntVersionString = view.getString 4, 0
    sfntVersionNumber = view.getFixed 0
    ttf.sfntHeader.sfntVersion = if (sfntVersionNumber == 1.0) then sfntVersionNumber else sfntVersionString
    
    # offset table
    if ttf.isTTF() and not ttf.isTTCF() or ttf.isOTTO()
      ttf.sfntHeader.numTables = view.getUshort 4
      ttf.sfntHeader.searchRange = view.getUshort()
      ttf.sfntHeader.entrySelector = view.getUshort()
      ttf.sfntHeader.rangeShift = view.getUshort()

      # offsetTable
      if ttf.sfntHeader.numTables > 0
        tableOffsets = {}

        ttf.offsetTable = for i in [0..ttf.sfntHeader.numTables-1]
          tag = view.getString 4
          checkSum = view.getUlong().toString(16)
          offset = view.getUlong()
          length = view.getUlong()
          tableOffsets[tag] = offset
          {
            tag: tag
            checkSum: checkSum
            offset: offset
            length: length
          }

        # head
        if typeof tableOffsets.head isnt 'undefined'
          ttf.head = HeadTable.createFromTTFDataView(view, tableOffsets.head, ttf)

        # maxp
        if typeof tableOffsets.maxp isnt 'undefined'
          ttf.maxp = MaxpTable.createFromTTFDataView(view, tableOffsets.maxp, ttf)

        # loca
        if typeof tableOffsets.loca isnt 'undefined'
          ttf.loca = LocaTable.createFromTTFDataView(view, tableOffsets.loca, ttf)

        # glyf
        if typeof tableOffsets.glyf isnt 'undefined'
          ttf.glyf = GlyfTable.createFromTTFDataView(view, tableOffsets.glyf, ttf)

        # hhea
        if typeof tableOffsets.hhea isnt 'undefined'
          ttf.hhea = HheaTable.createFromTTFDataView(view, tableOffsets.hhea, ttf)

        # hmtx
        if typeof tableOffsets.hmtx isnt 'undefined'
          ttf.hmtx = HmtxTable.createFromTTFDataView(view, tableOffsets.hmtx, ttf)
        
        # OS/2
        if typeof tableOffsets['OS/2'] isnt 'undefined'
          ttf.OS_2 = OS_2Table.createFromTTFDataView(view, tableOffsets['OS/2'], ttf)
        
        # cmap
        if typeof tableOffsets['cmap'] isnt 'undefined'
          ttf.cmap = CmapTable.createFromTTFDataView(view, tableOffsets['cmap'], ttf)
        
        # post
        if typeof tableOffsets['post'] isnt 'undefined'
          ttf.post = PostTable.createFromTTFDataView(view, tableOffsets['post'], ttf)


    # return ttf
    ttf


  # Create TrueType instance from JSON
  # @param {Object|String} json
  # @return {TrueType}
  @createFromJSON: (json) ->
    # init
    if typeof json == 'string'
      json = JSON.parse json

    ttf = new TrueType()

    # sfntHeader.sfntVersion
    ttf.sfntHeader.sfntVersion = json.sfntHeader.sfntVersion
    
    # offset table
    if ttf.isTTF() and not ttf.isTTCF() or ttf.isOTTO()
      ttf.sfntHeader.numTables = json.sfntHeader.numTables
      ttf.sfntHeader.searchRange = json.sfntHeader.searchRange
      ttf.sfntHeader.entrySelector = json.sfntHeader.entrySelector
      ttf.sfntHeader.rangeShift = json.sfntHeader.rangeShift

      # offsetTable
      if ttf.sfntHeader.numTables > 0
        
        ttf.offsetTable = json.offsetTable

        # head
        if typeof json.head isnt 'undefined'
          ttf.head = HeadTable.createFromJSON(json.head)

        # maxp
        if typeof json.maxp isnt 'undefined'
          ttf.maxp = MaxpTable.createFromJSON(json.maxp)

        # loca
        if typeof json.loca isnt 'undefined'
          ttf.loca = LocaTable.createFromJSON(json.loca)

        # glyf 
        if typeof json.glyf isnt 'undefined'
          ttf.glyf = GlyfTable.createFromJSON(json.glyf)

        # hhea
        if typeof json.hhea isnt 'undefined'
          ttf.hhea = HheaTable.createFromJSON(json.hhea)

        # hmtx
        if typeof json.hmtx isnt 'undefined'
          ttf.hmtx = HmtxTable.createFromJSON(json.hmtx)

        # OS_2
        if typeof json.OS_2 isnt 'undefined'
          ttf.OS_2 = OS_2Table.createFromJSON(json.OS_2)
        
        # cmap
        if typeof json.cmap isnt 'undefined'
          ttf.cmap = CmapTable.createFromJSON(json.cmap)
          
        # post
        if typeof json.post isnt 'undefined'
          ttf.cmap = PostTable.createFromJSON(json.post)

    # return ttf
    ttf


  # To JSON String
  # @return {String}
  toJSONString: () ->
    for glyph in @glyf.glyphs
      glyph.glyfTable = '[GlyfTable]'
    
    json = JSON.stringify.apply null, [@].concat(arguments)
    for glyph in @glyf.glyphs
      glyph.glyfTable = @glyf

    json

  

# exports
module.exports = TrueType

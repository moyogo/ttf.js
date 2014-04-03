# # ttf.js - JavaScript TrueType Font library
#
# Copyright (C) 2014 by Daton Maag Ltd.
#
# Released under the MIT license.

# ## Common Table Formats

# Lookup Types
GPOSLookupType = {
  1: 'SingleAdjustment',
  2: 'PairAdjustment',
  3: 'CursiveAttachment',
  4: 'MarkToBaseAttachment',
  5: 'MarkToLigatureAttachment',
  6: 'MarkToMarkAttachment',
  7: 'ContextPositioning',
  8: 'ChainContextPositioning',
  9: 'ExtensionPositioning'
}
GSUBLookupType = {
  1: 'Single',
  2: 'Multiple',
  3: 'Alternate',
  4: 'Ligature',
  5: 'Context',
  6: 'ChainingContext',
  7: 'ExtensionSubstitution',
  8: 'ReverseChainingContextSingle'
}

# Calculate the length of ValueRecord in bytes
valueFormatLength = (valueFormat) ->
    length = (valueFormat & 0x0001) / 0x0001 +
              (valueFormat & 0x0002) / 0x0002 +
              (valueFormat & 0x0004) / 0x0004 +
              (valueFormat & 0x0008) / 0x0008 +
              (valueFormat & 0x0010) / 0x0010 +
              (valueFormat & 0x0020) / 0x0020 +
              (valueFormat & 0x0040) / 0x0040 +
              (valueFormat & 0x0080) / 0x0080
    # return
    length
    
# ## Script List Table
class ScriptListTable
  constructor: () ->
    @scriptCount = 0
    @scriptRecord = []
  
  # Create ScriptListTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {ScriptListTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    scriptListTable = new ScriptListTable()
    
    scriptListTable.scriptCount = scriptCount = view.getUshort()
    if scriptCount > 0
      scriptRecord = []
      for i in [0..scriptCount-1]
        view.seek (offset + 2 + i*6)
        scriptTag = view.getString 4
        scriptOffset = view.getUshort()
        scriptTable = ScriptTable.createFromTTFDataView(view, offset + scriptOffset)
        scriptRecord.push {
          scriptTag: scriptTag
          script: scriptTable
        }
    
    scriptListTable.scriptRecord = scriptRecord
    
    # return
    scriptListTable
  
  # Create ScriptListTable from JSON
  # @param {Object|String} json
  # @return {ScriptListTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    scriptListTable = new ScriptListTable()
    
    scriptListTable.scriptCount = json.scriptCount
    
    for scriptRecord in json.scriptRecord
      scriptListTable.scriptRecord.push {
        scriptTag: scriptRecord.scriptTag
        script: ScriptTable.createFromJSON(scriptRecord.script)
      }
    
    # return
    scriptListTable

# ## Script Table
class ScriptTable
  constructor: () ->
    @langSysCount = 0
    @langSysRecord = []

  # Create ScriptTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {ScriptTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    scriptTable = new ScriptTable()
    
    defaultLangSysOffset = view.getUshort()
    scriptTable.langSysCount = langSysCount = view.getUshort()
    
    if langSysCount > 0
      langSysRecord = []
      for i in [0..langSysCount-1]
        view.seek (offset + 4 + i*6)
        
        langSysTag = view.getString 4
        langSysOffset = view.getUshort()
        langSys = LangSys.createFromTTFDataView(view, offset + langSysOffset)
        langSysRecord.push {
          langSysTag: langSysTag,
          langSys: langSys
        }
      
      scriptTable.langSysRecord = langSysRecord
    
    # return
    scriptTable
  
  # Create ScriptTable from JSON
  # @param {Object|String} json
  # @return {ScriptTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    scriptTable = new ScriptTable()
    
    scriptTable.langSysCount = json.langSysCount
    scriptTable.langSysRecord = json.langSysRecord
    
    
    # return
    scriptTable

# ## LangSys Table
class LangSys
  constructor: () ->
    @lookupOrder = null
    @reqFeatureIndex = 0xFFFF
    @featureCount = 0
    @featureIndex = []

  # Create LangSys instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {LangSys}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    langSys = new LangSys()
    
    langSys.lookupOrder = view.getUshort()
    langSys.reqFeatureIndex = view.getUshort()
    langSys.featureCount = featureCount = view.getUshort()
    
    if featureCount > 0
      featureIndex = []
      for i in [0..featureCount-1]
        featureIndex.push view.getUshort()
      langSys.featureIndex = featureIndex
    # return
    langSys
  
  # Create LangSys from JSON
  # @param {Object|String} json
  # @return {LangSys}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    langSys = new langSys()
    
    langSys.lookupOrder = json.lookupOrder
    langSys.reqFeatureIndex = json.lookupOrder
    langSys.featureCount = json.featureCount
    langSys.featureIndex = json.featureIndex
    
    # return
    langSys

# ## FeatureList Table
class FeatureListTable
  constructor: () ->
    @featureCount = 0
    @featureRecord = []
  
  # Create FeatureListTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {FeatureListTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    featureListTable = new FeatureListTable()    
    
    featureListTable.featureCount = featureCount = view.getUshort()
    
    if featureCount > 0
      featureRecord = []
      for i in [0..featureCount-1]
        view.seek (offset + 2 + 6*i)
        featureTag = view.getString 4
        featureOffset = view.getUshort()
        featureRecord.push {
          featureTag: featureTag,
          feature: FeatureTable.createFromTTFDataView(view, offset + featureOffset)
        }
      featureListTable.featureRecord = featureRecord
    
    # return
    featureListTable
  
  # Create FeatureListTable from JSON
  # @param {Object|String} json
  # @return {FeatureListTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json  
    
    featureListTable = new FeatureListTable()
    
    featureListTable.featureCount = json.featureCount
    featureListTable.featureRecord = json.featureRecord
    
    # return
    featureListTable

# ## Feature Table
class FeatureTable
  constructor: () ->
    @featureParams = null
    @lookupCount = 0
    @lookupListIndex = []

  # Create FeatureTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {FeatureTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    featureTable = new FeatureTable()
    
    featureTable.featureParams = view.getUshort()
    featureTable.lookupCount = lookupCount = view.getUshort()
    
    if lookupCount > 0
      lookupListIndex = []
      for i in [0..lookupCount-1]
        lookupListIndex.push view.getUshort()
      featureTable.lookupListIndex = lookupListIndex
    
    # return
    featureTable
  
  # Create FeatureTable from JSON
  # @param {Object|String} json
  # @return {FeatureTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json  
    
    featureTable = new FeatureTable()
    
    featureTable.featureParams = json.featureParams
    featureTable.lookupCount = json.lookupCount
    featureTable.lookupListIndex = json.lookupListIndex
    
    # return
    featureTable
    
# ## Lookup List Table
class LookupListTable
  constructor: () ->
    @lookupCount = 0
    @lookupTables = []
  
  # Create LookupListTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @param {String} table
  # @return {LookupListTable}
  @createFromTTFDataView: (view, offset, tableType) ->
    view.seek offset
    
    lookupListTable = new LookupListTable()
    lookupListTable.lookupCount = lookupCount = view.getUshort()
    
    if lookupCount > 0
      lookupTables = []
      for i in [0..lookupCount-1]
        view.seek (offset + 2 + i*2)
        
        lookupOffset = view.getUshort()
        lookupTable = LookupTable.createFromTTFDataView(view, offset + lookupOffset, tableType)
        lookupTables.push lookupTable
      lookupListTable.lookupTables = lookupTables
      
    # return
    lookupListTable
  
  # Create LookupListTable from JSON
  # @param {Object|String} json
  # @return {LookupListTable}
  @createFromJSON: (json, tableType) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    lookupListTable = new LookupListTable()
    
    lookupListTable.lookupCount = json.lookupCount
    
    return lookupListTable

# ## Lookup Table
class LookupTable
  constructor: () ->
    @lookupType = null
    @lookupFlag = null
    @subTableCount = 0
  
  # Create LookupTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {LookupTable}
  @createFromTTFDataView: (view, offset, tableType) ->
    view.seek offset
    
    lookupTable = new LookupTable()

    lookupTable.lookupType = view.getUshort()
    lookupTable.lookupFlag = view.getUshort()
    lookupTable.subTableCount = subTableCount = view.getUshort()
    
    if subTableCount > 0
      subTables = []
      
      for i in [0..subTableCount-1]
        view.seek (offset + 6 + i*2)
        
        subTableOffset = view.getUshort()
        
        if tableType is "GPOS"
          subTable = null
          # Get LookupType class from GPOSLookupType
          lookupTypeString = tableType + "LookupType[" + lookupTable.lookupType + "]"
          lookupTypeClass = eval lookupTypeString
          eval "subTable = " + lookupTypeClass + ".createFromTTFDataView(view, offset + subTableOffset)"
          subTables.push subTable
      lookupTable.subTables = subTables
    
    if (lookupTable.lookupFlag & 0x0010)
      view.seek (offset + 4 + i*subTableCount)
      lookupTable.markFilteringSet = view.getUshort()
    
    # return
    lookupTable
    
    # Create LookupTable from JSON
    # @param {Object|String} json
    # @return {LookupTable}
    # TODO

# ## GPOS SingleAdjustment, Lookup Type 1
class SingleAdjustment
  constructor: () ->
    @posFormat = null
  
  # Create SingleAdjustment instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {CoverageTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    singleAdjustment = new SingleAdjustment()
    
    singleAdjustment.posFormat = posFormat = view.getUshort()
    coverageOffset = view.getUshort()
    coverage = CoverageTable.createFromTTFDataView(view, offset + coverageOffset)
    singleAdjustment.coverage = coverage
    
    view.seek (offset + 4)
    
    valueFormat = view.getUshort()
    singleAdjustment.valueFormat = valueFormat
    
    formats = valueFormatLength(valueFormat)
    
    if posFormat is 1
      value = ValueRecord.createFromTTFDataView(view, offset + 6, valueFormat)
      singleAdjustment.value = value
    
    if posFormat is 2
      valueCount = view.getUshort()
      values = []
      
      if valueCount > 0
        for i in [0..valueCount-1]
          value = ValueRecord.createFromTTFDataView(view, offset + 8 + i*2*formats, valueFormat)
          values.push value
    
        singleAdjustment.values = values
    
    # return 
    singleAdjustment
    
    # Create SingleAdjustment from JSON
    # @param {Object|String} json
    # @return {SingleAdjustment}
    # TODO

# ## GPOS PairAdjustment, Lookup Type 2
class PairAdjustment
  constructor: () ->
    @posFormat = 1
  
  # Create Pairadjustment instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {Pairadjustment}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    pairAdjustment = new PairAdjustment()
    
    pairAdjustment.posFormat = posFormat = view.getUshort()
    
    if posFormat is 1
      coverageOffset = view.getUshort()
      pairAdjustment.valueFormat1 = valueFormat1 = view.getUshort()
      pairAdjustment.valueFormat2 = valueFormat2 = view.getUshort()
      pairAdjustment.pairSetCount = pairSetCount = view.getUshort()
      
      coverage = CoverageTable.createFromTTFDataView(view, offset + coverageOffset)
      pairAdjustment.coverage = coverage
      
      if pairSetCount > 0
        pairSets = []
        for i in [0..pairSetCount-1]
          view.seek (offset + 10 + i*2)
          
          pairSetOffset = view.getUshort()
          pairSet = PairSet.createFromTTFDataView(view, offset + pairSetOffset, valueFormat1, valueFormat2)
          pairSets.push pairSet
        
        pairAdjustment.pairSets = pairSets
      
    if posFormat is 2
      coverageOffset = view.getUshort()
      pairAdjustment.valueFormat1 = valueFormat1 = view.getUshort()
      pairAdjustment.valueFormat2 = valueFormat2 = view.getUshort()
      classDef1Offset = view.getUshort()
      classDef2Offset = view.getUshort()
      pairAdjustment.class1Count = class1Count = view.getUshort()
      pairAdjustment.class2Count = class2Count = view.getUshort()
      
      coverage = CoverageTable.createFromTTFDataView(view, offset + coverageOffset)
      classDef1 = ClassDefinitionTable.createFromTTFDataView(view, offset + classDef1Offset)
      classDef2 = ClassDefinitionTable.createFromTTFDataView(view, offset + classDef2Offset)
      
      pairAdjustment.coverage = coverage
      pairAdjustment.classDef1 = classDef1
      pairAdjustment.classDef2 = classDef2
      
      formats1 = valueFormatLength(valueFormat1)
      formats2 = valueFormatLength(valueFormat2)
      
      if class1Count > 0

        class1Records = []
        for i in [0..class1Count-1]
          value1 = ValueRecord.createFromTTFDataView(view, offset + 16 + i*2*formats1 + i*2*formats2, valueFormat1)
          value2 = ValueRecord.createFromTTFDataView(view, offset + 16 + (i+1)*2*formats1 + i*2*formats2, valueFormat2)
        
    
    # return
    pairAdjustment

    # Create PairAdjustment from JSON
    # @param {Object|String} json
    # @return {PairAdjustment}
    # TODO
    
# ## PairSet
class PairSet
  constructor: () ->
    @pairValueCount = 0
  
  # Create PairSet instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {PairSet}
  @createFromTTFDataView: (view, offset, valueFormat1, valueFormat2) ->
    view.seek offset
    
    pairSet = new PairSet()
    
    pairSet.pairValueCount = pairValueCount = view.getUshort()
    
    formats1 = (valueFormat1 & 0x0001) / 0x0001 +
               (valueFormat1 & 0x0002) / 0x0002 +
               (valueFormat1 & 0x0004) / 0x0004 +
               (valueFormat1 & 0x0008) / 0x0008 +
               (valueFormat1 & 0x0010) / 0x0010 +
               (valueFormat1 & 0x0020) / 0x0020 +
               (valueFormat1 & 0x0040) / 0x0040 +
               (valueFormat1 & 0x0080) / 0x0080
    formats2 = (valueFormat1 & 0x0001) / 0x0001 +
               (valueFormat1 & 0x0002) / 0x0002 +
               (valueFormat1 & 0x0004) / 0x0004 +
               (valueFormat1 & 0x0008) / 0x0008 +
               (valueFormat1 & 0x0010) / 0x0010 +
               (valueFormat1 & 0x0020) / 0x0020 +
               (valueFormat1 & 0x0040) / 0x0040 +
               (valueFormat1 & 0x0080) / 0x0080
               
    if pairValueCount > 0
      pairValues = []
      for i in [0..pairValueCount-1]
        view.seek (offset + 2 + i*2*formats1 + i*2*formats2)
        
        secondGlyph = view.getUshort()
        
        value1 = ValueRecord.createFromTTFDataView(view, offset + 4 + i*2*formats1 + i*2*formats2, valueFormat1)
        value2 = ValueRecord.createFromTTFDataView(view, offset + 4 + (i+1)*2*formats1 + i*2*formats2, valueFormat2)
        
        pairValue = {
          secondGlyph: secondGlyph
        }
        
        if valueFormat1
          pairValue.value1 = value1
        if valueFormat2
          pairValue.value2 = value2
        
        pairValues.push pairValue
      
      pairSet.pairValues = pairValues
    
    # return
    pairSet

    # Create PairSet from JSON
    # @param {Object|String} json
    # @return {PairSet}
    # TODO

# ## GPOS CursiveAttachment, Lookup Type 3
class CursiveAttachment
  constructor: () ->
    @posFormat = 1
  
  # Create CursiveAttachment instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {CursiveAttachment}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
      
    cursiveAttachment = new CursiveAttachment()
    cursiveAttachment.posFormat = view.getUshort()
    coverageOffset = view.getUshort()
    cursiveAttachment.entryExitCount  = entryExitCount = view.getUshort()
    
    coverage = CoverageTable.createFromTTFDataView(view, offset + coverageOffset)
    cursiveAttachment.coverage = coverage
    
    if entryExitCount > 0
      entryExitRecords = []
      for i in [0..entryExitCount-1]
        view.seek (offset + 6 + i*4)
        entryAnchorOffset = view.getUshort()
        exitAnchorOffset = view.getUshort()
        
        entryExitRecord = {}
        if entryAnchorOffset isnt 0
          entryAnchor = AnchorTable.createFromTTFDataView(view, offset + entryAnchorOffset)
          entryExitRecord.entryAnchor = entryAnchor
        if exitAnchorOffset isnt 0
          exitAnchor = AnchorTable.createFromTTFDataView(view, offset + exitAnchorOffset)
          entryExitRecord.exitAnchor = exitAnchor

        entryExitRecords.push entryExitRecord
      cursiveAttachment.entryExitRecords = entryExitRecords
    
    # return 
    cursiveAttachment
    
    # Create CursiveAttachment from JSON
    # @param {Object|String} json
    # @return {CursiveAttachment}
    # TODO
    
# ## GPOS MarkToBaseAttachment, Lookup Type 4
class MarkToBaseAttachment
  constructor: () ->
    @posFormat = 1
  
  # Create MarkToBaseAttachment instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {MarkToBaseAttachment}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    markToBaseAttachment = new MarkToBaseAttachment()
    
    markToBaseAttachment.posFormat = view.getUshort()
    markCoverageOffset = view.getUshort()
    baseCoverageOffset = view.getUshort()
    classCount = view.getUshort()
    markArrayOffset = view.getUshort()
    baseArrayOffset = view.getUshort()
    
    markToBaseAttachment.markCoverage = CoverageTable.createFromTTFDataView(view, offset + markCoverageOffset)
    markToBaseAttachment.baseCoverage = CoverageTable.createFromTTFDataView(view, offset + baseCoverageOffset)
    
    markArray = MarkArray.createFromTTFDataView(view, offset + markArrayOffset)
    baseArray = BaseArray.createFromTTFDataView(view, offset + baseArrayOffset)
   
    markToBaseAttachment.markArray = markArray
    markToBaseAttachment.baseArray = baseArray 

    # return 
    markToBaseAttachment
    
    # Create MarkToBaseAttachment from JSON
    # @param {Object|String} json
    # @return {MarkToBaseAttachment}
    # TODO

# ## GPOS MarkToLigatureAttachment, Lookup Type 5
class MarkToLigatureAttachment
  constructor: () ->
  
  # Create MarkToLigatureAttachment instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {MarkToLigatureAttachment}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    markToLigatureAttachment = new MarkToLigatureAttachment()
    
    markToLigatureAttachment.posFormat = posFormat = view.getUshort()
    markCoverageOffset = view.getUshort()
    ligatureCoverageOffset = view.getUshort()
    markToLigatureAttachment.classCount = classCount = view.getUshort()
    markArrayOffset = view.getUshort()
    ligatureArrayOffset = view.getUshort()
    
    markCoverage = CoverageTable.createFromTTFDataView(view, offset + markCoverageOffset)
    ligatureCoverage = CoverageTable.createFromTTFDataView(view, offset + ligatureCoverageOffset)
    
    markArray = MarkArray.createFromTTFDataView(view, offset + markArrayOffset)
    ligatureArray = LigatureArray.createFromTTFDataView(view, offset + ligatureArrayOffset, classCount)
    
    # return
    markToLigatureAttachment

    # Create MarkToLigatureAttachment from JSON
    # @param {Object|String} json
    # @return {MarkToLigatureAttachment}
    # TODO
        
# ## LigatureArray
class LigatureArray
  constructor: () ->
    
  # Create LigatureArray instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @param {Number} classCount
  # @return {LigatureArray}
  @createFromTTFDataView: (view, offset, classCount) ->
    view.seek offset
    
    ligatureArray = new LigatureArray()
    ligatureArray.ligatureCount = ligatureCount = view.getUshort()
    
    if ligatureCount > 0
      ligatureAttachs = []
      for i in [0..ligatureCount-1]
        ligatureAttachOffset = view.getUshort()
        
        ligatureAttach = LigatureAttach.createFromTTFDataView(view, offset + ligatureAttachOffset, classCount)
        ligatureAttachs.push ligatureAttach
      ligatureArray.ligatureAttachs = ligatureAttachs
    
    # return
    ligatureArray


# ## LigatureAttach
class LigatureAttach
  constructor: () ->
  
  # Create LigatureAttach instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @param {Number} classCount
  # @return {LigatureAttach}
  @createFromTTFDataView: (view, offset, classCount) ->
    view.seek offset
    
    ligatureAttach = new LigatureAttach()
    
    ligatureAttach.componentCount = componentCount = view.getUshort()
    if componentCount > 0
      componentRecords = []
      
      for i in [0..componentCount-1]
        if classCount > 0
          componentRecord = []
          
          for j in [0..classCount-1]
            view.seek (offset + 2 + i*2*classCount + j*2)
              
            ligatureAnchorOffset = view.getUshort()
            
            ligatureAnchor = AnchorTable.createFromTTFDataView(view, offset + ligatureAnchorOffset)
            componentRecord.push ligatureAnchor
        
          componentRecords.push componentRecord
          
    ligatureAttach.componentRecords = componentRecords
    
    # return
    ligatureAttach

    # Create LigatureAttach from JSON
    # @param {Object|String} json
    # @return {LigatureAttach}
    # TODO

# ## GPOS MarkToMarkAttachment, Lookup Type 6
class MarkToMarkAttachment
  constructor: () ->
    @posFormat = 1
  
  # Create MarkToMarkAttachment instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {MarkToMarkAttachment}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    markToMarkAttachment = new MarkToMarkAttachment()
    
    markToMarkAttachment.posFormat = posFormat = view.getUshort()
    mark1CoverageOffset = view.getUshort()
    mark2CoverageOffset = view.getUshort()
    markToMarkAttachment.classCount = classCount = view.getUshort()
    mark1ArrayOffset = view.getUshort()
    mark2ArrayOffset = view.getUshort()
    
    mark1Coverage = CoverageTable.createFromTTFDataView(view, offset + mark1CoverageOffset)
    mark2Coverage = CoverageTable.createFromTTFDataView(view, offset + mark2CoverageOffset)
    mark1Array = MarkArray.createFromTTFDataView(view, offset + mark1ArrayOffset)
    mark2Array = Mark2Array.createFromTTFDataView(view, offset + mark2ArrayOffset)
    
    markToMarkAttachment.mark1Coverage = mark1Coverage
    markToMarkAttachment.mark2Coverage = mark2Coverage
    markToMarkAttachment.mark1Array = mark1Array
    markToMarkAttachment.mark2Array = mark2Array
    
    # return 
    markToMarkAttachment
    
    # Create MarkToMarkAttachment from JSON
    # @param {Object|String} json
    # @return {MarkToMarkAttachment}
    # TODO

# ## GPOS Mark2Array (same as GPOS BaseArray)
class Mark2Array
  constructor: () ->
    @baseCount = 0
    
  # Create Mark2Array instance from TTFDataview
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {Mark2Array}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
  
    mark2Array = new Mark2Array()
    mark2Array.mark2Count = mark2Count = view.getUshort()
    
    if mark2Count > 0
      mark2Records = []
      for i in [0..mark2Count-1]
        view.seek (offset + 2 + i*2)
        mark2AnchorOffset = view.getUshort()
        mark2Anchor = AnchorTable.createFromTTFDataView(view, offset + baseAnchorOffset)
        
        mark2Record = {
          mark2Anchor: mark2anchor
        }
        mark2Records.push mark2Record
    
    mark2Array.mark2Records = mark2Records

    # return
    mark2Array
    
    # Create Mark2Array from JSON
    # @param {Object|String} json
    # @return {Mark2Array}
    # TODO

class Mark2Array
  constructor: () ->

  # Create Mark2Array instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {Mark2Array}  
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    mark2Array = new Mark2Array
    
    mark2AnchorOffset = view.getUshort()
    
# ## GPOS ContextPositioning, Lookup Type 7

# ## GPOS ChainContextPositioning, Lookup Type 8
class ChainContextPositioning
  constructor: () ->
    
  # Create ChainContextPositioning instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {ChainContextPositioning}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    chainContextPositioning = new ChainContextPositioning()
    
    chainContextPositioning.posFormat = posFormat = view.getUshort()
    
    if posFormat is 1
      coverageOffset = view.getUshort()
      chainContextPositioning.chainPosRuleSetCount = chainPosRuleSetCount = view.getUshort()
      
      coverage = CoverageTable.createTTFFromDataView(view, coverageOffset)
      
      if chainPosRuleSetCount > 0
        chainPosRuleSets = []
        for i in [0..chainPosRuleSetCount-1]
          view.seek (offset + 6 + i*2)
          chainPosRuleSetOffset = view.getUshort()
          
          view.seek (offset + chainPosRuleSetOffset)
          
          chainPosRuleCount = view.getUshort()
          
          if chainPosRuleCount > 0
            chainPosRules = []
            for j in [0..chainPosRuleCount-1]
              view.seek (offset + chainPosRuleSetOffset + 2 + j*2)
              chainPosRuleOffset = view.getUshort()
              
              chainPosRule = ChainPosRule.createFromTTFDataView(view, offset + chainPosRuleOffset)
              
              chainPosRules.push chainPosRule
          
          chainPosRuleSet = {
            chainPosRuleCount: chainPosRuleCount,
            chainPosRules: chainePosRules
          }
          
          chainPosRuleSets.push chainPosRuleSet
      
        chainContextPositioning.chainPosRuleSets = chainPosRuleSets
      
      if posFormat is 2
        coverageOffset = view.getUshort()
        backtrackClassDefOffset = view.getUshort()
        inputClassDefOffset = view.getUshort()
        lookAheadClassDefOffset = view.getUshort()
        chainContextPositioning.chainPosClassSetCount = chainPosClassSetcount = view.getUshort()
        
        if chainPosClassSetcount > 0
          chainPosClassSets = []
          for i in [0..chainPosClassSetcount-1]
            view.seek (offset + 12 + i*2)
            chainPosClassSetOffset = view.getUshort()
            
            chainPosClassSet = ChainPosClassSet.createFromTTFDataView(view, offset + chainPosClassSetOffset)
                          
          
          
        
        chainContextPositioning.coverage = CoverageTable.createFromTTFDataView(view, offset + coverageOffset)
        chainContextPositioning.backtrackClassDef = ClassDefinitionTable(view, offset + backtrackClassDefOffset)
        chainContextPositioning.inputClassDef = ClassDefinitionTable(view, offset + inputClassDefOffset)
        
    
    # return
    chainContextPositioning

# ## ChainPosRule
class ChainPosRule
  constructor: () ->
  
  # Create ChainPosRule instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {ChainPosRule}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    chainPosRule = new ChainPosRule()
    
    chainPosRule.backtrackGlyphCount = backtrackGlyphCount = view.getUshort()
    
    if backtrackGlyphCount > 0
      backtracks = []
      for i in [0..backtrackGlyphCount-1]
        backtrack = view.getUshort()
        backtracks.push backtrack
      chainPosRule.backtracks = backtracks
    
    chainPosRule.inputGlyphCount = inputGlyphCount = view.getUshort()
    
    if inputGlyphCount-1 > 0
      inputs = []
      for i in [0..inputGlyphCount-2]
        input = view.getUshort()
        inputs.push input
      chainPosRule.inputs = inputs
    
    chainPosRule.lookAheadGlyphCount = lookAheadGlyphCount = view.getUshort()
    
    if lookAheadGlyphCount > 0
      lookAheads = []
      for i in [0..lookAheadGlyphCount-1]
        lookAhead= view.getUshort()
        lookAheads.push lookAhead
      chainPosRule.lookAheads = lookAheads
    
    chainPosRule.posCount = posCount = view.getUshort()
    
    if posCount  > 0
      posLookupRecords = []
      for i in [0..posCount -1]
        sequenceIndex = view.getUshort()
        lookupIndex = view.getUshort()
        posLookupRecord= {
          sequenceIndex: sequenceIndex,
          lookupIndex: lookupIndex
        }
        posLookupRecords.push posLookupRecord
      chainPosRule.posLookupRecords = posLookupRecords
  
    # return
    chainPosRule

# ## ChainPosClassSet
class ChainPosClassSet
  constructor: () ->
  
  # Create ChainPosClassSet instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {ChainPosClassSet}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    chainPosClassSet = new ChainPosClassSet()
    
    chainPosClassRuleCount = view.getUshort()
            
    if chainPosClassRuleCount > 0
      chainPosClassRules = []
      for i in [0..chainPosClassRuleCount]
        view.seek (offset + 2 + 2*i)
        chainPosClassRuleOffset = view.getUshort()
        chainPosClassRule = ChainPosClassRule.createFromTTFDataView(view, offset + chainPosClassRuleOffset)
        chainPosClassRules.push chainPosClassRule
      chainPosClassSet.chainPosClassRules = chainPosClassRules
    
    # return
    chainPosClassSet

# ## ChainPosClassRule
class ChainPosClassRule
  constructor: () ->

  # Create ChainPosClassRule instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {ChainPosClassRule}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    chainPosClassRule = new ChainPosClassRule()
    
    chainPosClassRule.backtrackGlyphCount = backtrackGlyphCount = view.getUshort()
    
    if backtrackGlyphCount > 0
      backtracks = []
      for i in [0..backtrackGlyphCount-1]
        backtrack = view.getUshort()
        backtracks.push backtrack
      chainPosClassRule.backtracks = backtracks
    
    chainPosClassRule.inputGlyphCount = inputGlyphCount = view.getUshort()
    
    if inputGlyphCount > 0
      inputs = []
      for i in [0..inputGlyphCount-2]
        input = view.getUshort()
        inputs.push input
      chainPosClassRule.inputs = inputs
    
    chainPosClassRule.lookAheadGlyphCount = lookAheadGlyphCount = view.getUshort()
    
    if lookAheadGlyphCount > 0
      lookAheads = []
      for i in [0..lookAheadGlyphCount-1]
        lookAhead = view.getUshort()
        lookAheads.push lookAhead
      chainPosClassRule.lookAheads = lookAheads
    
    chainPosClassRule.posCount = posCount = view.getUshort()
    
    if posCount  > 0
      posLookupRecords = []
      for i in [0..posCount -1]
        sequenceIndex = view.getUshort()
        lookupIndex = view.getUshort()
        posLookupRecord= {
          sequenceIndex: sequenceIndex,
          lookupIndex: lookupIndex
        }
        posLookupRecords.push posLookupRecord
      chainPosClassRule.posLookupRecords = posLookupRecords  
    
    # return
    chainPosClassRule

# ## GPOS ExtensionPositioning, Lookup Type 9
class ExtensionPositioning
  constructor: () ->
  
  # Create ExtensionPositioning instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {ExtensionPositioning}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    extensionPositioning = new ExtensionPositioning()
    
    extensionPositioning.posFormat = view.getUshort()
    extensionPositioning.extensionLookupType = view.getUshort()
    # must be se to lookup type other than 9
    extensionOffset = view.getUlong()
    
    extension = Extension.createFromTTFDataView(view, offset)
    # TODO
    
    # return
    extensionPositioning

# ## GPOS AnchorTable
class AnchorTable
  constructor: () ->
    @anchorFormat = null
  
  # Create AnchorTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {AnchorTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    anchorTable = new AnchorTable()
    
    anchorTable.anchorFormat = anchorFormat = view.getUshort()
    
    anchorTable.xCoordinate = view.getShort()
    anchorTable.yCoordinate = view.getShort()
    
    if anchorFormat is 2
      anchorTable.anchorPoint = view.getUshort()
    if anchorFormat is 3
      xDeviceTableOffset = view.getUshort()
      yDeviceTableOffset = view.getUshort()
      
      anchorTable.xDeviceTable = DeviceTable.createFromTTFDataView(view, offset + xDeviceTableOffset)
      anchorTable.yDeviceTable = DeviceTable.createFromTTFDataView(view, offset + yDeviceTableOffset)
    
    # return
    anchorTable
  
  # TODO
  # Create AnchorTable from JSON
 
# ## GPOS MarkArray
class MarkArray
  constructor: () ->
    @markCount = 0

  # Create MarkArray instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {MarkArray}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    
    markArray = new MarkArray()
    markArray.markCount = markCount = view.getUshort()
    
    if markCount > 0
      markRecords = []
      for i in [0..markCount-1]
        view.seek (offset + 2 + i*4)
        markClass = view.getUshort()
        markAnchorOffset = view.getUshort()
        markAnchor = AnchorTable.createFromTTFDataView(view, offset + markAnchorOffset)
        
        markRecord = {
          markClass: markClass,
          markAnchor: markAnchor
        }
        markRecords.push markRecord
      markArray.markRecords = markRecords

    # return
    markArray
    
    # TODO
    # Create MarkArray from JSON

# ## GPOS BaseArray
class BaseArray
  constructor: () ->
    @baseCount = 0
    
  # Create BaseArray instance from TTFDataview
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {BaseArray}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
  
    baseArray = new BaseArray()
    baseArray.baseCount = baseCount = view.getUshort()
    
    if baseCount > 0
      baseRecords = []
      for i in [0..baseCount-1]
        view.seek (offset + 2 + i*2)
        baseAnchorOffset = view.getUshort()
        baseAnchor = AnchorTable.createFromTTFDataView(view, offset + baseAnchorOffset)
        
        baseRecord = {
          baseAnchor: baseAnchor
        }
        baseRecords.push baseRecord
    
    baseArray.baseRecords = baseRecords

    # return
    baseArray

    # TODO
    # Create BaseArray from JSON

# ## Value Record Class
class ValueRecord
  constructor: () ->
  
  # Create ValueRecord instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {ValueRecord}
  @createFromTTFDataView: (view, offset, valueFormat) ->
    view.seek offset
    
    valueRecord = new ValueRecord()
    
    if (valueFormat & 0x0001)
      valueRecord.xPlacement = view.getShort()
    if (valueFormat & 0x0002)
      valueRecord.yPlacement = view.getShort()
    if (valueFormat & 0x0004)
      valueRecord.xAdvance = view.getShort()
    if (valueFormat & 0x0008)
      valueRecord.yAdvance = view.getShort()
    if (valueFormat & 0x0010)
      xPlaDeviceOffset = view.getUshort()
      if (xPlaDeviceOffset isnt null and xPlaDeviceOffset isnt 'undefined')
        valueRecord.xPlaDevice = DeviceTable.createFromTTFDataView(view, offset + xPlaDeviceOffset)
    if (valueFormat & 0x0020)
      yPlaDeviceOffset = view.getUshort()
      if (yPlaDeviceOffset isnt null and yPlaDeviceOffset isnt 'undefined')
        valueRecord.yPlaDevice = DeviceTable.createFromTTFDataView(view, offset + yPlaDeviceOffset)
    if (valueFormat & 0x0040)
      xAdvDeviceOffset = view.getUshort()
      if (xAdvDeviceOffset isnt null and xAdvDeviceOffset isnt 'undefined')
        valueRecord.xAdvDevice = DeviceTable.createFromTTFDataView(view, offset + xAdvDeviceOffset)
    if (valueFormat & 0x0080)
      yAdvDeviceOffset = view.getUshort()
      if (yAdvDeviceOffset isnt null and yAdvDeviceOffset isnt 'undefined')
        valueRecord.yAdvDevice = DeviceTable.createFromTTFDataView(view, offset + yAdvDeviceOffset)

    # return
    valueRecord
    
# ## Coverage Table Class
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
    
    classDefTable = new ClassDefinitionTable()
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

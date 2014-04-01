# # ttf.js - JavaScript TrueType Font library
#
# Copyright (C) 2014 by ynakajima (https://github.com/ynakajima)
# Copyright (C) 2014 by Daton Maag Ltd.
#
# Released under the MIT license.

Common = require ('./Common')

# ## GPOS table Class
class GPOSTable
  constructor: () ->
    @version = 0
    
  # Create GPOSTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @return {GPOSTable}
  @createFromTTFDataView: (view, offset) ->
    view.seek offset
    GPOS = new GPOSTable()
    
    GPOS.version = version = view.getFixed()
    scriptListOffset = view.getUshort()
    featureListOffset = view.getUshort()
    lookupListOffset = view.getUshort()
    
    scriptList = ScriptListTable.createFromTTFDataView(view, offset + scriptListOffset)
    featureList = FeatureListTable.createFromTTFDataView(view, offset + featureListOffset)
    lookupList = LookupListTable.createFromTTFDataView(view, offset + lookupListOffset, "GPOS")
    
    GPOS.scriptList = scriptList
    GPOS.featureList = featureList
    GPOS.lookupList = lookupList
    
    # return
    GPOS

  # Create GPOSTable from JSON
  # @param {Object|String} json
  # @return {GPOSTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    GPOS = new GPOSTable()
    GPOS.version = json.version
    
    GPOS.scriptList = ScriptListTable.createFromJSON(json.scriptList)
    GPOS.featureList = FeatureListTable.createFromJSON(json.featureList)
    GPOS.lookupList = LookupListTable.createFromJSON(json.lookupList, "GPOS")
    
    # return
    GPOS
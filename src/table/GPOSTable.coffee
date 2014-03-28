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
    

  # Create GPOSTable from JSON
  # @param {Object|String} json
  # @return {GPOSTable}
  @createfromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json
    
    GPOS = new GPOSTable()
# # ttf.js - JavaScript TrueType Font library
#
# Copyright (C) 2014 by ynakajima (https://github.com/ynakajima)
# Copyright (C) 2014 by Daton Maag Ltd.
#
# Released under the MIT license.

standardNames = [".notdef", ".null", "nonmarkingreturn", "space", "exclam",
 "quotedbl", "numbersign", "dollar", "percent", "ampersand", "quotesingle",
 "parenleft", "parenright", "asterisk", "plus", "comma", "hyphen", "period",
 "slash", "zero", "one", "two", "three", "four", "five", "six", "seven",
 "eight", "nine", "colon", "semicolon", "less", "equal", "greater", "question",
 "at", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N",
 "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "bracketleft",
 "backslash", "bracketright", "asciicircum", "underscore", "grave", "a", "b",
 "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q",
 "r", "s", "t", "u", "v", "w", "x", "y", "z", "braceleft", "bar", "braceright",
 "asciitilde", "Adieresis", "Aring", "Ccedilla", "Eacute", "Ntilde",
 "Odieresis", "Udieresis", "aacute", "agrave", "acircumflex", "adieresis",
 "atilde", "aring", "ccedilla", "eacute", "egrave", "ecircumflex", "edieresis",
 "iacute", "igrave", "icircumflex", "idieresis", "ntilde", "oacute", "ograve",
 "ocircumflex", "odieresis", "otilde", "uacute", "ugrave", "ucircumflex",
 "udieresis", "dagger", "degree", "cent", "sterling", "section", "bullet",
 "paragraph", "germandbls", "registered", "copyright", "trademark", "acute",
 "dieresis", "notequal", "AE", "Oslash", "infinity", "plusminus", "lessequal",
 "greaterequal", "yen", "mu", "partialdiff", "summation", "product", "pi",
 "integral", "ordfeminine", "ordmasculine", "Omega", "ae", "oslash",
 "questiondown", "exclamdown", "logicalnot", "radical", "florin", "approxequal",
 "Delta", "guillemotleft", "guillemotright", "ellipsis", "nonbreakingspace",
 "Agrave", "Atilde", "Otilde", "OE", "oe", "endash", "emdash", "quotedblleft",
 "quotedblright", "quoteleft", "quoteright", "divide", "lozenge", "ydieresis",
 "Ydieresis", "fraction", "currency", "guilsinglleft", "guilsinglright", "fi",
 "fl", "daggerdbl", "periodcentered", "quotesinglbase", "quotedblbase",
 "perthousand", "Acircumflex", "Ecircumflex", "Aacute", "Edieresis", "Egrave",
 "Iacute", "Icircumflex", "Idieresis", "Igrave", "Oacute", "Ocircumflex",
 "apple", "Ograve", "Uacute", "Ucircumflex", "Ugrave", "dotlessi", "circumflex",
 "tilde", "macron", "breve", "dotaccent", "ring", "cedilla", "hungarumlaut",
 "ogonek", "caron", "Lslash", "lslash", "Scaron", "scaron", "Zcaron", "zcaron",
 "brokenbar", "Eth", "eth", "Yacute", "yacute", "Thorn", "thorn", "minus",
 "multiply", "onesuperior", "twosuperior", "threesuperior", "onehalf",
 "onequarter", "threequarters", "franc", "Gbreve", "gbreve", "Idotaccent",
 "Scedilla", "scedilla", "Cacute", "cacute", "Ccaron", "ccaron", "dcroat" ]

# ## Post table Class
class PostTable
  constructor: () ->
    @version = 0
    @italicAngle = 0
    @underlinePosition = 0
    @underlineThickness = 0
    @isFixedPitch = 0
    @minMemType42 = 0
    @maxMemType42 = 0
    @mimMemType1 = 0
    @maxMemType1 = 0

  # Create PostTable instance from TTFDataView
  # @param {TTFDataView} view
  # @param {Number} offset
  # @param {TrueType} ttf
  # @return {PostTable}
  @createFromTTFDataView: (view, offset, ttf) ->
    view.seek offset
    post = new PostTable()

    post.version = view.getFixed()
    post.italicAngle = view.getFixed()
    post.underlinePosition = view.getFWord()
    post.underlineThickness = view.getFWord()
    post.isFixedPitch = view.getUlong()
    post.minMemType42 = view.getUlong()
    post.maxMemType42 = view.getUlong()
    post.minMemType1 = view.getUlong()
    post.maxMemType1 = view.getUlong()

    if post.version is 1
      names = []
      for i in [0..standardNames.length]
        names.push {
          gId: i,
          name: standardNames[i]
        }

    if post.version is 2
      numGlyphs = view.getUshort()

      glyphNameIndex = []
      names = []
      for i in [0..numGlyphs-1]
        glyphNameIndex.push view.getUshort()

      for i in [0..numGlyphs-1]
        glyphNameId = ""
        if glyphNameIndex[i] < standardName.length
          # get default glyph name
          glyphNameId = standardNames[glyphNameIndex[i]]
          name = glyphNameId
        else
          glyphNameId = glyphNameIndex[i] - standardName.length
          nameLength = view.getByte()
          name = view.getString nameLength
        names.push {
          gId: i,
          name: name
          }
      post.names = names

    post

  # Create PostTable from JSON
  # @param {Object|String} json
  # @return {PostTable}
  @createFromJSON: (json) ->
    if typeof json == 'string'
      json = JSON.parse json

    post = new PostTable()

    post.version = json.version
    post.italicAngle = json.italicAngle
    post.underlinePosition = json.underlinePosition
    post.underlineThickness = json.underlineThickness
    post.isFixedPitch = json.isFixedPitch
    post.minMemType42 = json.minMemType42
    post.maxMemType42 = json.maxMemType42
    post.mimMemType1 = json.mimMemType1
    post.maxMemType1 = json.maxMemType1
    post.names = json.names

    post

  # Return GlyphName at the specified id
  # @param {Number} id id of Glyph
  # @return {String}
  getGlyphNameById: (id) ->
    glyphName = false
    name = @names[parseInt(id)]
    if parseInt(name.gId) is parseInt(id)
      glyphName = name.name
    else
      for name in @names
        if parseInt(name.gId, 10) is parseInt(id, 10)
          glyphName = name.name
    glyphName

# exports
module.exports = PostTable

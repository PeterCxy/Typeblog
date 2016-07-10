{Plugin, dependencies} = require 'plugin'
{Promise} = dependencies
highlight = require 'highlight.js'

class HighlighterPlugin extends Plugin
  highlight: (code, lang) ->
    promise = Promise.try ->
      if lang?
        return highlight.highlight(lang, code).value
      else
        return highlight.highlightAuto(code).value

    return [true, promise]

module.exports = new HighlighterPlugin
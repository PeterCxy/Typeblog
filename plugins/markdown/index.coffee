{Plugin, dependencies, callPluginMethod} = require 'plugin'
{Promise} = dependencies
marked = require 'marked'

marked.setOptions highlight: (code, lang, cb) ->
  callPluginMethod 'highlight', [code, lang]
    .then (result) -> cb null, result
    .catch (err) -> cb null, code

class MarkdownPlugin extends Plugin
  parseContentMarkdown: (content) ->
    promise = new Promise (resolve, reject) ->
      marked content, (err, result) ->
        if err?
          reject err
        else
          resolve result

    return [true, promise]

  highlight: (code, lang) ->
    return [true, Promise.try ->
      return code
    ]

module.exports = new MarkdownPlugin
{Plugin, dependencies} = require 'plugin'
{Promise, fs} = dependencies

class DefaultPlugin extends Plugin
  constructor: ->
    # The default one need not to be registered

  transformExpressApp: (app) ->
    # Do nothing by default
    return [true, Promise.try ->
      # ???
    ]

  loadPost: (file) ->
    promise = fs.readFileAsync file
      .then (buf) -> buf.toString()
    return [true, promise]

  parsePost: (content) ->
    end = content.indexOf '```\n'
    return [false, null] if not (content.startsWith('```json') and end > 0)
    start = '```json'.length + 1

    promise = Promise.try ->
      json = content[start...end]
      data = JSON.parse json
      data.content = content[end + '```'.length...].trim()
      return data
    .then (data) ->
      if not (data.title? and data.date?)
        throw new Error 'You must provide at least `title` and `date`'
      if not data.parser?
        data.parser = 'Default'
      if not data.url?
        data.url = encodeURIComponent data.title
      return data
    .then (data) ->
      data.date = new Date data.date
      return data

    return [true, promise]

  parseContentDefault: (content) ->
    promise = Promise.try ->
      return content # Do no change on the content
    return [true, promise]

module.exports = new DefaultPlugin()
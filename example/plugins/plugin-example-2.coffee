{Plugin} = require 'plugin'

class Example2Plugin extends Plugin
  transformExpressApp: ->
    return [false, (app) ->
      app.get '/plugin/example2', (req, res) ->
        res.send 'Hello, plugins (2)!'
      return app
    ]

  transformRenderResult: ->
    return [false, (content) ->
      return content.replace 'Typeblog', 'Typeblog_2'
    ]

module.exports = new Example2Plugin
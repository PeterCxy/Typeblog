{Plugin} = require 'plugin'

class ExamplePlugin extends Plugin
  transformExpressApp: ->
    return [false, (app) ->
      app.get '/plugin/example', (req, res) ->
        res.send 'Hello, plugins!'
      return app
    ]

  transformRenderResult: ->
    return [false, (content) ->
      return content.replace 'Typeblog', 'Typeblog_1'
    ]

module.exports = new ExamplePlugin
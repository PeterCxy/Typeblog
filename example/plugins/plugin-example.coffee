{Plugin} = require 'plugin'

class ExamplePlugin extends Plugin
  transformExpressApp: (app) ->
    app.get '/plugin/example', (req, res) ->
      res.send 'Hello, plugins!'

module.exports = new ExamplePlugin
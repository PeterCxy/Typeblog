```json
{
  "title": "Hello, 世界",
  "url": "test/hello-world-1",
  "date": "2016-07-09",
  "parser": "Markdown"
}
```

This is the hello-world post! __test__

```
{Plugin} = require 'plugin'

class ExamplePlugin extends Plugin
  transformExpressApp: (app) ->
    app.get '/plugin/example', (req, res) ->
      res.send 'Hello, plugins!'

module.exports = new ExamplePlugin
```

The following should be an incorrect highlighting

```bash
{Plugin} = require 'plugin'

class ExamplePlugin extends Plugin
  transformExpressApp: (app) ->
    app.get '/plugin/example', (req, res) ->
      res.send 'Hello, plugins!'

module.exports = new ExamplePlugin
```
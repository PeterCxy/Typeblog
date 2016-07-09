{fs} = require './dependencies'
{EventEmitter} = require 'events'

class Configuration extends EventEmitter
  constructor: ->
    @config = {}

  reload: ->
    fs.readFileAsync './config.json'
      .then JSON.parse
      .then (config) => @config = config
      .then => @emit 'change', @config
      .catch (e) ->
        console.error e
        process.exit 1

module.exports = new Configuration()
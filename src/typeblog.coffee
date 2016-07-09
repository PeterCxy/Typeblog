{fs} = require './utils/dependencies'

# Check for the existence of config.json in the current working directory
fs.statAsync "./config.json"
  .then (stats) ->
    # File exists, load and serve the blog.
    configuration = require('./utils/configuration')
    configuration.once 'change', ->
      require('./server').start()
    configuration.reload()
  .catch (e) ->
    console.error e
    console.error 'Unable to stat config.json in the current working directory. Make sure this is a folder with a Typeblog structure.'